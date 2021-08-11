part of 'isolator.dart';

/// Class, which must be a ancestor of your backend classes
abstract class Backend<TEvent> with BackendChunkMixin<TEvent>, BackendOnErrorMixin<TEvent>, BackendInitMixin<TEvent>, BackendSyncMixin<TEvent> {
  Backend(BackendArgument<void> argument)
      : _fromFront = ReceivePort(),
        _fromMessageBus = ReceivePort(),
        _sendPortToFront = argument.toFrontend,
        _sendPortToMessageBus = argument.messageBusSendPort {
    _senderToFront = _Sender<TEvent, dynamic>(argument.toFrontend);
    IsolatorConfig._instance.setParamsFromJson(argument.config);
    _fromFront.listen(_rawMessageHandler);
    _fromMessageBus.listen(_rawBusMessageHandler);
    _sendPortToFrontend();
    _initializerCompleter = Completer();
    init();
    _checkInitialization();
  }

  final SendPort _sendPortToFront;
  final SendPort? _sendPortToMessageBus;
  final ReceivePort _fromFront;
  final ReceivePort _fromMessageBus;
  final Map<String, Completer<dynamic>> _syncResults = {};
  bool get _isMessageBusBackend => _sendPortToMessageBus == null;

  /// Collection of your backend's operations, which will be executed on events from frontend
  @protected
  Map<TEvent, Function> get operations;

  @protected
  Map<dynamic, Function> get busHandlers => <dynamic, Function>{};

  @protected
  void _sendMessageToAnotherBackend(Type backendType, dynamic messageBusEventId, [dynamic value]) {
    final _Message<dynamic, Packet3<Type, Type, dynamic>> message = _Message<dynamic, Packet3<Type, Type, dynamic>>(
      messageBusEventId,
      value: Packet3<Type, Type, dynamic>(backendType, runtimeType, value),
    );
    _sendPortToMessageBus?.send(message);
  }

  @protected
  Future<TResponse> _runAnotherBackendMethod<TResponse>(Type backendToType, dynamic messageBusEventId, [Object? value]) async {
    if (_sendPortToMessageBus == null) {
      throw Exception('Can\'t call this method from MessageBusBackend');
    }
    final Completer<TResponse> completer = Completer();
    final String code = Utils.generateCode<dynamic>(messageBusEventId);
    _syncResults[code] = completer;
    final _Message<dynamic, Packet3<Type, Type, Object?>> message = _Message<dynamic, Packet3<Type, Type, Object?>>(
      messageBusEventId,
      value: Packet3(backendToType, runtimeType, value),
      code: code,
      serviceParam: _ServiceParam.anotherBackendMethodRequest,
    );
    _sendPortToMessageBus!.send(message);
    final TResponse response = await completer.future;
    return response;
  }

  @protected
  Future<List<TResponse>> _runAnotherBackendMethodWithListResponse<TResponse>(Type backendToType, dynamic messageBusEventId, [Object? value]) async {
    assert(TResponse != dynamic);
    final List<dynamic> response = await _runAnotherBackendMethod<List<dynamic>>(backendToType, messageBusEventId, value);
    return response.cast<TResponse>().toList();
  }

  /// Method for sending events with any data to frontend
  @protected
  void send(TEvent eventId, [Object? value]) {
    if (_codes.any((String code) => Utils.isCodeAndIdValid(eventId, code))) {
      throw Exception('Sync launched methods must return value, and not send event with the same id');
    }
    final _Message<TEvent, Object?> message = _Message<TEvent, Object?>(eventId, value: value);
    if (!_isMessageBusBackend) {
      Logger.sendToFrontend(eventId, value);
    }
    _senderToFront.send(message);
  }

  void _sendPortToFrontend() {
    _sendPortToFront.send(Packet2(_fromFront.sendPort, _isMessageBusBackend ? null : _fromMessageBus.sendPort));
  }

  Future<void> _rawMessageHandler(dynamic message) async {
    final bool isTypesCorresponding = message.id.runtimeType == TEvent;
    final bool isMessageForBus = _sendPortToMessageBus == null;
    if (isMessageForBus && !isTypesCorresponding) {
      final _Message typedMessage = message as _Message;
      final Packet3 messageData = typedMessage.value as Packet3;
      final Type backendToType = messageData.value as Type;
      final Type backendFromType = messageData.value2 as Type;
      final dynamic messagePayload = messageData.value3;
      final String targetIsolateId = Isolator.generateBackendId(backendToType);
      await busMessageHandler(
          targetIsolateId, typedMessage.id, Packet3<Type, Type, dynamic>(backendFromType, backendToType, messagePayload), typedMessage.code);
    } else {
      await _messageHandler(message as _Message<TEvent, dynamic>);
    }
  }

  Future<void> _rawBusMessageHandler(dynamic message) async {
    final _Message<dynamic, dynamic> typedMessage = message as _Message<dynamic, dynamic>;
    if (message.code != null) {
      await _completeSyncMessage(message);
      return;
    }
    final bool hasValue = typedMessage.value != null && typedMessage.value is Packet3 && (typedMessage.value as Packet3).value3 != null;
    if (busHandlers.containsKey(typedMessage.id)) {
      final Function handler = busHandlers[typedMessage.id]!;
      final bool needToPassValue = hasValue && Utils.isFunctionWithParam(handler);
      if (needToPassValue) {
        handler((message.value as Packet3).value3);
      } else {
        handler();
      }
    } else if (operations.containsKey(typedMessage.id)) {
      final Function operation = operations[typedMessage.id]!;
      final bool needToPassValue = hasValue && Utils.isFunctionWithParam(operation);
      if (needToPassValue) {
        operation((message.value as Packet3).value3);
      } else {
        operation();
      }
    }
  }

  Future<void> _completeSyncMessage(_Message<dynamic, dynamic> message) async {
    final String code = message.code!;
    final Completer<dynamic>? completer = _syncResults[code];
    if (message.isErrorMessage) {
      return;
    }
    if (completer == null) {
      // Call handler in second Backend, which assume message from first
      Function? operation;
      if (operations.containsKey(message.id)) {
        operation = operations[message.id];
      } else if (busHandlers.containsKey(message.id)) {
        operation = busHandlers[message.id];
      }
      if (operation == null) {
        throw Exception('Not found method for id ${message.id}');
      }
      dynamic value;

      if (message.value is! Packet3) {
        throw Exception('Sync message must contain Packet3<BackendFromType, BackendToType, Value> param as a value');
      }
      final Packet3 messageData = message.value as Packet3;
      final Type backendFromType = messageData.value as Type;
      final Type backendToType = messageData.value2 as Type;
      final dynamic messagePayload = messageData.value3;
      if (messagePayload != null || Utils.isFunctionWithParam(operation)) {
        value = operation(messagePayload);
      } else {
        value = operation();
      }
      if (value is Future) {
        value = await value;
      }
      final _Message<dynamic, dynamic> responseMessage = _Message<dynamic, dynamic>(
        message.id,
        code: code,
        value: Packet3<Type, Type, dynamic>(backendFromType, backendToType, value),
      );
      _sendPortToMessageBus!.send(responseMessage);
      return;
    }
    if (!Utils.isCodeAndIdValid<dynamic>(message.id, code)) {
      throw Exception('Event id ${message.id} is not similar as firstly given id ${Utils.getIdFromCode(code)}');
    }
    final Packet3 value = message.value as Packet3;
    completer.complete(value.value3);
  }

  /// Used only in MessageBusBackend
  @protected
  Future<void> busMessageHandler(String isolateId, dynamic messageId, Packet3<Type, Type, dynamic> value, String? code) async {}

  Future<void> _messageHandler<TVal>(_Message<TEvent, TVal?> message) async {
    if (!_isMessageBusBackend) {
      Logger.gotFromFrontend(message.id, message.value);
      Logger.durationOnBackend(DateTime.now().difference(message.timestamp).inMicroseconds / 1000, message.id);
    }

    final TEvent id = message.id;
    final Function? operation = operations[id];
    if (operation == null) {
      throw Exception('Operation for ID $id is not found in operations');
    }
    if (!_isInitialized) {
      await _initializerCompleter.future;
    }
    if (message.code != null) {
      _codes.add(message.code!);
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
    final bool withParam = Utils.isFunctionWithParam(operation);
    TVal? result;
    try {
      if (withParam) {
        result = await operation(message.value) as TVal?;
      } else {
        result = await operation() as TVal?;
      }
    } catch (err) {
      _sendError(message.id, err);
      await onError(message.id, err);

      /// Part of "sync" logic
      if (message.code != null) {
        _sendSync(id, err.toString(), message.code!, true);
      }
      rethrow;
    }
    if (message.code != null) {
      _sendSync(id, result, message.code!);
      return;
    }
    if (result != null) {
      send(id, result);
    }
  }
}
