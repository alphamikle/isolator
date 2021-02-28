part of 'isolator.dart';

typedef Creator<TDataType> = void Function(BackendArgument<TDataType> argument);

class IsolatorData<T> {
  const IsolatorData(this.data, this.config);

  final T data;
  final IsolatorConfig config;
}

mixin Frontend<TEventType> {
  bool _isInitialized = false;
  Stream<_Message<TEventType, dynamic>> _fromBackend;
  _Sender<TEventType, dynamic> _toBackend;
  StreamSubscription<_Message<TEventType, dynamic>> _subscription;
  final Map<TEventType, Function> _eventsCallbacks = {};
  final Map<String, Completer<dynamic>> _syncResults = {};

  /// Used for logging
  String _withValue(dynamic value) => value == null || !IsolatorConfig._instance.showValuesInLogs ? '' : ' with value $value';

  /// Used for logging
  String _prefixTo(TEventType eventId) => '[Frontend: $runtimeType $eventId] >>>';

  /// Used for logging
  String _prefixFrom(TEventType eventId) => '[Frontend: $runtimeType $eventId] <<<';

  String get _isolateId => '${runtimeType.toString()}Backend';

  /// Method for creating disposable, single-use subscriptions
  void onEvent(TEventType event, Function func) {
    _eventsCallbacks[event] = func;
  }

  /// Method for creating backend of this frontend state
  @protected
  Future<void> initBackend<TDataType extends Object>(Creator<TDataType> creator, {TDataType data, ErrorHandler errorHandler}) async {
    final _Communicator<TEventType, dynamic> communicator = await Isolator.isolate<TEventType, dynamic, TDataType>(
      creator,
      _isolateId,
      isolatorData: IsolatorData(data, IsolatorConfig._instance),

      /// Error handler is a function for handle errors from backend on frontend (prefer to handle errors on backend)
      errorHandler: errorHandler ?? onError,
    );
    _toBackend = communicator.toBackend;
    _fromBackend = communicator.fromBackend;
    await _subscription?.cancel();
    _subscription = _fromBackend.asBroadcastStream().listen(_responseFromBackendHandler);
    _isInitialized = true;
  }

  @protected
  void killBackend() {
    Isolator.kill(_isolateId);
  }

  /// Method for sending event with any data to backend
  @protected
  void send<TValueType extends Object>(TEventType eventId, [TValueType value]) {
    assert(_isInitialized, 'You must call "initBackend" method before send data');
    final _Message<TEventType, TValueType> message = _Message(eventId, value);
    if (IsolatorConfig._instance.logEvents) {
      print('${_prefixTo(eventId)} Send message from frontend to backend ${_withValue(value)}');
    }
    _toBackend.send(message);
  }

  /// Hook on errors, which have [eventId]
  Future<void> _onIdError(TEventType eventId, dynamic error) async {
    if (errorsHandlers.containsKey(eventId)) {
      final ErrorHandler handler = errorsHandlers[eventId];
      final dynamic result = handler(error);
      if (result is Future) {
        await result;
      }
      onBackendResponse();
    }
  }

  /// Hook on every error
  @protected
  Future<void> onError(dynamic error) async {}

  /// Method for sending event with any data to backend
  @protected
  Future<TResponseType> runBackendMethod<TValueType extends Object, TResponseType>(TEventType eventId, [TValueType value]) async {
    assert(_isInitialized, 'You must call "initBackend" method before send data');
    final Completer<TResponseType> completer = Completer();
    final String code = Utils.generateCode(eventId);
    _syncResults[code] = completer;
    final _Message<TEventType, TValueType> message = _Message(eventId, value, code);
    if (IsolatorConfig._instance.logEvents) {
      print('${_prefixTo(eventId)} Run backend\'s method in sync mode in frontend ${_withValue(value)}');
    }
    _toBackend.send(message);
    final TResponseType result = await completer.future;
    if (IsolatorConfig._instance.logEvents) {
      print('${_prefixFrom(eventId)} Got a response from backend\'s method in sync mode in frontend ${_withValue(result)}');
    }
    return result;
  }

  Future<void> _completeSyncMessage(_Message<TEventType, dynamic> message) async {
    final Completer<dynamic> completer = _syncResults[message.code];
    if (message.isErrorMessage) {
      print('${_prefixFrom(message.id)} runBackendMethod ends with error ${message.value}');
      return;
    }
    if (completer == null) {
      throw Exception('Not found completer for operation ${message.id} with code ${message.code} and value ${message.value}');
    }
    if (!Utils.isCodeAndIdValid(message.id, message.code)) {
      throw Exception('Event id ${message.id} is not similar as firstly given id ${Utils.getIdFromCode(message.code)}');
    }
    final dynamic value = message.value;
    completer.complete(value);
    onBackendResponse();
  }

  /// Private backend's events handler, which run public handler and execute event's subscriptions
  Future<void> _responseFromBackendHandler(_Message<TEventType, dynamic> message) async {
    if (message.isErrorMessage) {
      if (IsolatorConfig._instance.logErrors) {
        print('${_prefixFrom(message.id)} An error was thrown in backend, see logs for additional information');
      }
      _onIdError(message.id, message.value);
      if (message.code != null) {
        _completeSyncMessage(message);
      }
      return;
    }
    final List<FrontendObserver> observers = IsolatorConfig._instance.frontendObservers;
    if (observers.isNotEmpty) {
      for (final FrontendObserver observer in observers) {
        await observer(Message(message.id, message.value));
      }
    }

    if (IsolatorConfig._instance.logTimeOfDataTransfer) {
      print(
          '${_prefixFrom(message.id)} Duration of transmission of this message from backend to frontend was ${DateTime.now().difference(message.timestamp).inMicroseconds / 1000}ms');
    }

    /// Part of logic of "sync" methods
    if (message.code != null) {
      _completeSyncMessage(message);
    } else {
      if (IsolatorConfig._instance.logEvents) {
        print('${_prefixFrom(message.id)} Got a message from backend ${_withValue(message.value)}');
      }
      await responseFromBackendHandler(message);
    }
    if (_isMessageIdHasCallbacks(message.id)) {
      if (IsolatorConfig._instance.logEvents) {
        print('${_prefixFrom(message.id)} Run callback on event');
      }
      _eventsCallbacks[message.id]();
      _eventsCallbacks.remove(message.id);
    }
  }

  bool _isMessageIdHasCallbacks(TEventType id) => _eventsCallbacks.containsKey(id);

  /// Hook on every data, passed from backend to frontend
  @protected
  void onBackendResponse() {}

  /// Functions (tasks), which will executed by frontend on accordingly to events from backend
  @protected
  Map<TEventType, Function> get tasks;

  /// Functions (handlers), which will executed, when error was thrown in backend after sending corresponding message with [eventId] from frontend
  /// each handler can have a one dynamic argument - then in that handlers will pass a error
  @protected
  Map<TEventType, ErrorHandler> get errorsHandlers => {};

  /// Default handler of backend events
  @protected
  Future<void> responseFromBackendHandler(_Message<TEventType, dynamic> message) async {
    final Function task = tasks[message.id];
    if (task != null) {
      if (message.value != null || Utils.isFunctionWithParam(task)) {
        if (IsolatorConfig._instance.logEvents) {
          print('${_prefixFrom(message.id)} Try to running task, which have argument ${_withValue(message.value)}');
        }
        task(message.value);
      } else {
        if (IsolatorConfig._instance.logEvents) {
          print('${_prefixFrom(message.id)} Try to running task without argument ${_withValue(message.value)}');
        }
        task();
      }
    }
    onBackendResponse();
  }
}
