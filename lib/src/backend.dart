part of 'isolator.dart';

/// Class, which must be a ancestor of your backend classes
abstract class Backend<TEventType> {
  Backend(this._sendPortToFront)
      : _fromFront = ReceivePort(),
        _senderToFront = _Sender<TEventType, dynamic>(_sendPortToFront) {
    _fromFront.listen((dynamic val) => _messageHandler<dynamic>(val as _Message<TEventType, dynamic>));
    _sendPortToFrontend();
    _initializerCompleter = Completer();
    init();
  }

  final SendPort _sendPortToFront;
  final _Sender<TEventType, dynamic> _senderToFront;
  final ReceivePort _fromFront;
  final Set<String> _codes = {};

  /// Collection of your backend's operations, which will be executed on events from frontend
  @protected
  Map<TEventType, Function> get operations;

  bool _isInitialized = false;
  Completer<bool> _initializerCompleter;

  /// Hook on start backend
  @protected
  @mustCallSuper
  Future<void> init() async {
    _isInitialized = true;
    _initializerCompleter.complete(true);
  }

  /// Hook, which will handle your backend's errors
  @protected
  Future<void> handleErrors(TEventType event, dynamic error) async {}

  /// Method for sending events with any data to frontend
  @protected
  void send<TValueType extends Object>(TEventType eventId, [TValueType value]) {
    if (_codes.any((String code) => _Utils.isCodeAndIdValid(eventId, code))) {
      throw Exception('Sync launched methods must return value, and not send event with the same id');
    }
    final _Message message = _Message<TEventType, TValueType>(eventId, value);
    _senderToFront.send(message);
  }

  void _sendSync<TValueType extends Object>(TEventType eventId, TValueType value, String code) {
    final _Message message = _Message<TEventType, TValueType>(eventId, value, code);
    _senderToFront.send(message);
    _codes.remove(message.code);
  }

  void _sendPortToFrontend() {
    _sendPortToFront.send(_fromFront.sendPort);
  }

  Future<void> _messageHandler<TValueType>(_Message<TEventType, TValueType> message) async {
    final TEventType id = message.id;
    final Function operation = operations[id];
    if (operation == null) {
      throw Exception('Operation for ID $id is not found in operations');
    }
    if (!_isInitialized) {
      await _initializerCompleter.future;
    }
    if (message.code != null) {
      _codes.add(message.code);
    }

    /// Example of function without params
    /// Closure: () => Future<String> from Function '_funcWithoutParams@266394741':.
    /// Example of function with params
    /// Closure: ([dynamic]) => Future<String> from Function '_funcWithParams@67394741':.
    final bool withParam = _Utils.isFunctionWithParam(operation.toString());
    dynamic result;
    try {
      if (withParam) {
        result = await operation(message.value);
      } else {
        result = await operation();
      }
    } catch (err) {
      await handleErrors(message.id, err);
      if (message.code != null) {
        _sendSync(id, err, message.code);
      }
      rethrow;
    }
    if (message.code != null) {
      _sendSync(id, result, message.code);
      return;
    }
    if (result != null) {
      send<TValueType>(id, result);
    }
  }
}
