part of 'isolator.dart';

/// Class, which must be a ancestor of your backend classes
abstract class Backend<TEventType, TDataType> {
  Backend(BackendArgument<TDataType> argument)
      : _fromFront = ReceivePort(),
        _sendPortToFront = argument.toFrontend,
        _senderToFront = _Sender<TEventType, dynamic>(argument.toFrontend) {
    IsolatorConfig._instance.setParamsFromJson(argument.config);
    _fromFront.listen((dynamic val) => _messageHandler<dynamic>(val as _Message<TEventType, dynamic>));
    _sendPortToFrontend();
    _initializerCompleter = Completer();
    init();
    _checkInitialization();
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

  /// Used for logging
  String _prefixTo(TEventType eventId) => '[Backend: $runtimeType $eventId] >>>';

  /// Used for logging
  String _prefixFrom(TEventType eventId) => '[Backend: $runtimeType $eventId] <<<';

  /// Check, if backend was initialized in timeout (can be helpful, when you place complex logic in [init] method of backend
  void _checkInitialization() {
    Future<void>.delayed(IsolatorConfig._instance.backendInitTimeout, () {
      if (!_isInitialized) {
        throw Exception('$runtimeType not initialized in ${IsolatorConfig._instance.backendInitTimeout.inMilliseconds}ms');
      } else if (IsolatorConfig._instance.logEvents) {
        print('[$runtimeType] Was completely initialized');
      }
    });
  }

  /// Hook on start backend
  @protected
  @mustCallSuper
  Future<void> init() async {
    _isInitialized = true;
    _initializerCompleter.complete(true);
  }

  /// Hook, which will handle your backend's errors
  @protected
  Future<void> onError(TEventType event, dynamic error) async {}

  /// Method for sending events with any data to frontend
  @protected
  void send<TValueType extends Object>(TEventType eventId, [TValueType value]) {
    if (_codes.any((String code) => _Utils.isCodeAndIdValid(eventId, code))) {
      throw Exception('Sync launched methods must return value, and not send event with the same id');
    }
    final _Message message = _Message<TEventType, TValueType>(eventId, value);
    if (IsolatorConfig._instance.logEvents) {
      print('${_prefixTo(message.id)} Send message from backend to frontend');
    }
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
    if (IsolatorConfig._instance.logEvents) {
      print('${_prefixFrom(message.id)} Got a message from frontend');
    }

    if (IsolatorConfig._instance.logTimeOfDataTransfer) {
      print('${_prefixFrom(message.id)} Duration of transmission of this message from frontend to backend was ${DateTime.now().difference(message.timestamp).inMicroseconds / 1000}ms');
    }

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

    /// Example of functions with and without params
    /// ---> () => void
    /// false
    /// ---> (int) => void
    /// true
    /// ---> () => void
    /// false
    /// ---> (String) => void
    /// true
    final bool withParam = _Utils.isFunctionWithParam(operation);
    dynamic result;
    try {
      if (withParam) {
        result = await operation(message.value);
      } else {
        result = await operation();
      }
    } catch (err) {
      await onError(message.id, err);

      /// Part of "sync" logic
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
