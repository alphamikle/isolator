part of 'isolator.dart';

typedef Creator<TDataType> = void Function(BackendArgument<TDataType> argument);

mixin BackendMixin<TEventType> {
  bool _isInitialized = false;
  Stream<_Message<TEventType, dynamic>> _fromBackend;
  _Sender<TEventType, dynamic> _toBackend;
  StreamSubscription<_Message<TEventType, dynamic>> _subscription;
  final Map<TEventType, Function> _eventsCallbacks = {};
  final Map<String, Completer<dynamic>> _syncResults = {};

  /// Method for creating disposable subscriptions
  void onEvent(TEventType event, Function func) {
    _eventsCallbacks[event] = func;
  }

  /// Method for creating backend of this frontend state
  @protected
  Future<void> initBackend<TDataType extends Object>(Creator<TDataType> creator, {TDataType data, ErrorHandler errorHandler}) async {
    final _Communicator<TEventType, dynamic> communicator = await Isolator.isolate<TEventType, dynamic, TDataType>(
      creator,
      '${runtimeType.toString()}Backend',
      data: data,

      /// Error handler is a function for handle errors from backend on frontend (prefer to handle errors on backend)
      errorHandler: errorHandler,
    );
    _toBackend = communicator.toBackend;
    _fromBackend = communicator.fromBackend;
    await _subscription?.cancel();
    _subscription = _fromBackend.asBroadcastStream().listen(_responseFromBackendHandler);
    _isInitialized = true;
  }

  /// Method for sending event with any data to backend
  @protected
  void send<TValueType extends Object>(TEventType eventId, [TValueType value]) {
    assert(_isInitialized, 'You must call "initBackend" method before send data');
    final _Message<TEventType, TValueType> message = _Message(eventId, value);
    _toBackend.send(message);
  }

  /// Method for sending event with any data to backend
  @protected
  Future<TResponseType> runBackendMethod<TValueType extends Object, TResponseType>(TEventType eventId, [TValueType value]) async {
    assert(_isInitialized, 'You must call "initBackend" method before send data');
    final Completer<TResponseType> completer = Completer();
    final String code = _Utils.generateCode(eventId);
    _syncResults[code] = completer;
    final _Message<TEventType, TValueType> message = _Message(eventId, value, code);
    _toBackend.send(message);
    return completer.future;
  }

  /// Private backend's events handler, which run public handler and execute event's subscriptions
  void _responseFromBackendHandler(_Message<TEventType, dynamic> message) {
    if (message.code != null) {
      final Completer<dynamic> completer = _syncResults[message.code];
      if (completer == null) {
        throw Exception('Not found completer for operation ${message.id} with code ${message.code} and value ${message.value}');
      }
      if (!_Utils.isCodeAndIdValid(message.id, message.code)) {
        throw Exception('Event id ${message.id} is not similar as firstly given id ${_Utils.getIdFromCode(message.code)}');
      }
      final dynamic value = message.value;
      completer.complete(value);
      onBackendResponse();
    } else {
      responseFromBackendHandler(message);
    }
    if (_isMessageIdHasCallbacks(message.id)) {
      _eventsCallbacks[message.id]();
      _eventsCallbacks.remove(message.id);
    }
  }

  bool _isMessageIdHasCallbacks(TEventType id) => _eventsCallbacks.containsKey(id);

  /// Hook on every data, passed from backend to frontend
  @protected
  void onBackendResponse() {}

  /// Functions (tasks), which will executed by frontend on accordingly to  events from backend
  @protected
  Map<TEventType, Function> get tasks;

  /// Default handler of backend events
  @protected
  void responseFromBackendHandler(_Message<TEventType, dynamic> message) {
    final Function task = tasks[message.id];
    if (task != null) {
      if (message.value != null) {
        task(message.value);
      } else {
        task();
      }
    }
    onBackendResponse();
  }
}
