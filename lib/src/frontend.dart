part of 'isolator.dart';

typedef Creator<TDataType> = void Function(BackendArgument<TDataType> argument);

class IsolatorData<T> {
  const IsolatorData(this.data, this.config);

  final T? data;
  final IsolatorConfig config;
}

mixin Frontend<TEvent> {
  bool _isInitialized = false;
  late Stream<_Message<TEvent, Object?>> _fromBackend;
  late _Sender<TEvent, Object?> _toBackend;
  StreamSubscription<_Message<TEvent, Object?>>? _subscription;
  final Map<TEvent, Function> _eventsCallbacks = {};
  final Map<String, Completer<Object>> _syncResults = {};
  final Map<TEvent, List<Object>> _chunksData = {};
  String _id = '';
  bool get _canLog => _id != _MESSAGE_BUS;

  @protected
  SendPort get backendSendPort => _toBackend.sendPort;

  /// Method for creating disposable, single-use subscriptions
  void onEvent(TEvent event, Function func) {
    print('Callback for event $event was registered');
    _eventsCallbacks[event] = func;
  }

  /// Method for creating backend of this frontend state
  @protected
  Future<void> initBackend<TDataType>(
    Creator<TDataType> creator, {
    required Type backendType,
    TDataType? data,
    ErrorHandler? errorHandler,
    String uniqueId = '',
    bool isMessageBus = false,
  }) async {
    if (uniqueId.isEmpty) {
      _id = Isolator.generateBackendId(backendType);
    } else {
      _id = uniqueId;
    }
    final _Communicator<TEvent, Object?> communicator = await Isolator.isolate<TEvent, Object?, TDataType>(
      creator,
      _id,
      isolatorData: IsolatorData(data, IsolatorConfig._instance),

      /// Error handler is a function for handle errors from backend on frontend (prefer to handle errors on backend)
      errorHandler: errorHandler ?? onError,
      isMessageBus: isMessageBus,
    );
    _toBackend = communicator.toBackend;
    _fromBackend = communicator.fromBackend;
    await _subscription?.cancel();
    _subscription = _fromBackend.asBroadcastStream().listen(_responseFromBackendHandler);
    _isInitialized = true;
  }

  @protected
  void killBackend() {
    _isInitialized = false;
    Isolator.kill(_id);
  }

  /// Method for sending event with any data to backend
  @protected
  void send<TVal>(TEvent eventId, [TVal? value]) {
    assert(_isInitialized, 'You must call "initBackend" method before send data');
    final _Message<TEvent, TVal?> message = _Message(eventId, value: value);
    if (_canLog) {
      Logger.sendToBackend(eventId, value);
    }
    _toBackend.send(message);
  }

  /// Hook on errors, which have [eventId]
  Future<void> _onIdError(TEvent eventId, dynamic error) async {
    if (errorsHandlers.containsKey(eventId)) {
      final ErrorHandler handler = errorsHandlers[eventId]!;
      final dynamic result = handler(error);
      if (result is Future) {
        await result;
      }
      onBackendResponse();
    }
  }

  void _errorHandler(_Message<TEvent, Object?> message) {
    if (_canLog) {
      Logger.frontendError(message.id);
    }
    _onIdError(message.id, message.value);
    if (message.code != null) {
      _completeSyncMessage(message);
    }
  }

  Future<void> _observersHandler(_Message<TEvent, Object?> message) async {
    final List<FrontendObserver> observers = IsolatorConfig._instance.frontendObservers;
    if (observers.isNotEmpty) {
      for (final FrontendObserver observer in observers) {
        await observer(Message<TEvent, Object?>(message.id, message.value));
      }
    }
  }

  Future<void> _publicRunner<TVal extends Object?>(_Message<TEvent, TVal?> message) async {
    if (message.code != null) {
      await _completeSyncMessage(message);
    } else {
      if (_canLog) {
        Logger.gotFromBackend(message.id, message.value);
      }
      await responseFromBackendHandler(message);
    }
  }

  void _callbacksRunner<TVal>(_Message<TEvent, TVal?> message) {
    if (_isMessageIdHasCallbacks(message.id)) {
      if (_canLog) {
        Logger.frontendCallback(message.id);
      }
      _eventsCallbacks[message.id]!();
      _eventsCallbacks.remove(message.id);
    }
  }

  void _startChunkTransactionHandler<TVal extends Object>(_Message<TEvent, List<TVal>> message) {
    // print('Start adding data by chunks: ${message.id} / ${message.value?.length}');
    _chunksData[message.id] = message.value!;
  }

  void _addDataToChunk<TVal extends Object>(_Message<TEvent, List<TVal>> message) {
    // print('Add data via chunks: ${message.id} / ${message.value?.length}');
    _chunksData[message.id]!.addAll(message.value!);
  }

  void _clearTransactionData(_Message<TEvent, void> message) {
    // print('Clear data from transaction with: ${message.id}');
    _chunksData.remove(message.id);
  }

  _Message<TEvent, List<TVal>> _endChunkTransactionHandler<TVal extends Object>(_Message<TEvent, List<TVal>> message) {
    // print('End adding data by chunks: ${message.id} / ${message.value?.length}');
    final List<TVal> allChunksData = _chunksData[message.id]! as List<TVal>;
    message.value!.insertAll(0, allChunksData);
    _chunksData.remove(message.id);
    return message;
  }

  /// Hook on every error
  @protected
  Future<void> onError(dynamic error) async {}

  /// Method for sending event with any data to backend
  @protected
  Future<TResponse> runBackendMethod<TVal extends Object, TResponse extends Object>(TEvent eventId, [TVal? value]) async {
    assert(_isInitialized, 'You must call "initBackend" method before send data');
    final Completer<TResponse> completer = Completer();
    final String code = Utils.generateCode(eventId);
    _syncResults[code] = completer;
    final _Message<TEvent, TVal?> message = _Message(eventId, value: value, code: code);
    if (_canLog) {
      Logger.runBackendMethod(eventId, value);
    }
    _toBackend.send(message);
    final TResponse result = await completer.future;
    if (_canLog) {
      Logger.gotFromBackendMethod(eventId, value);
    }
    return result;
  }

  Future<void> _completeSyncMessage<TVal>(_Message<TEvent, TVal?> message) async {
    final String code = message.code!;
    final Completer<dynamic>? completer = _syncResults[code];
    if (message.isErrorMessage) {
      return;
    }
    if (completer == null) {
      throw Exception('Not found completer for operation ${message.id} with code $code and value ${message.value}');
    }
    if (!Utils.isCodeAndIdValid(message.id, code)) {
      throw Exception('Event id ${message.id} is not similar as firstly given id ${Utils.getIdFromCode(code)}');
    }
    final TVal? value = message.value;
    completer.complete(value);
    onBackendResponse();
  }

  /// Private backend's events handler, which run public handler and execute event's subscriptions
  Future<void> _responseFromBackendHandler<TVal extends Object?>(_Message<TEvent, TVal?> message) async {
    final double sendTime = DateTime.now().difference(message.timestamp).inMicroseconds / 1000;
    if (message.isErrorMessage) {
      _errorHandler(message);
      return;
    }
    await _observersHandler(message);

    if (_canLog) {
      Logger.durationOnFrontend(sendTime, message.id);
      Logger.longDurationOnFrontend(sendTime, message.id);
    }

    if (message.isStartOfTransaction) {
      _startChunkTransactionHandler(message as _Message<TEvent, List<Object>>);
      if (message.withUpdate) {
        await responseFromBackendHandler(message);
      }
      return;
    } else if (message.isTransferencePieceOfTransaction) {
      _addDataToChunk(message as _Message<TEvent, List<Object>>);
      return;
    } else if (message.isEndOfTransaction) {
      final _Message<TEvent, List<Object>> chunkMessage = _endChunkTransactionHandler(message as _Message<TEvent, List<Object>>);
      _callbacksRunner<List<Object>>(chunkMessage);
      await _publicRunner<List<Object>>(chunkMessage);
      return;
    } else if (message.isCancelingOfTransaction) {
      _clearTransactionData(message);
      return;
    }

    _callbacksRunner<TVal>(message);
    await _publicRunner<TVal>(message);
  }

  bool _isMessageIdHasCallbacks(TEvent id) => _eventsCallbacks.containsKey(id);

  /// Hook on every data, passed from backend to frontend
  @protected
  void onBackendResponse() {}

  /// Functions (tasks), which will executed by frontend on accordingly to events from backend
  @protected
  Map<TEvent, Function> get tasks;

  /// Functions (handlers), which will executed, when error was thrown in backend after sending corresponding message with [eventId] from frontend
  /// each handler can have a one dynamic argument - then in that handlers will pass a error
  @protected
  Map<TEvent, ErrorHandler> get errorsHandlers => {};

  /// Default handler of backend events
  @protected
  Future<void> responseFromBackendHandler<TVal extends Object?>(_Message<TEvent, TVal?> message) async {
    final Function? task = tasks[message.id];
    if (task != null) {
      if (message.value != null || Utils.isFunctionWithParam(task)) {
        task(message.value);
      } else {
        task();
      }
    }
    onBackendResponse();
  }
}
