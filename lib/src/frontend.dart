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

  /// Used for logging
  String _withValue(dynamic value) => (value == null || !IsolatorConfig._instance.showValuesInLogs) ? '' : ' with value $value';

  /// Used for logging
  String _prefixTo(TEvent eventId) => '[Frontend: $runtimeType $eventId] >>>';

  /// Used for logging
  String _prefixFrom(TEvent eventId) => '[Frontend: $runtimeType $eventId] <<<';

  String get _defaultId => '${runtimeType.toString()}Backend';

  /// Method for creating disposable, single-use subscriptions
  void onEvent(TEvent event, Function func) {
    _eventsCallbacks[event] = func;
  }

  /// Method for creating backend of this frontend state
  @protected
  Future<void> initBackend<TDataType>(Creator<TDataType> creator, {TDataType? data, ErrorHandler? errorHandler, String id = ''}) async {
    _id = '$_defaultId$id';
    final _Communicator<TEvent, Object?> communicator = await Isolator.isolate<TEvent, Object?, TDataType>(
      creator,
      _id,
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
    _isInitialized = false;
    Isolator.kill(_id);
  }

  /// Method for sending event with any data to backend
  @protected
  void send<TVal>(TEvent eventId, [TVal? value]) {
    assert(_isInitialized, 'You must call "initBackend" method before send data');
    final _Message<TEvent, TVal?> message = _Message(eventId, value: value);
    if (IsolatorConfig._instance.logEvents) {
      print('${_prefixTo(eventId)} Send message from frontend to backend ${_withValue(value)}');
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
    if (IsolatorConfig._instance.logErrors) {
      print('${_prefixFrom(message.id)} An error was thrown in backend, see logs for additional information');
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
        await observer(Message(message.id, message.value));
      }
    }
  }

  Future<void> _publicRunner<TVal extends Object?>(_Message<TEvent, TVal?> message) async {
    if (message.code != null) {
      _completeSyncMessage(message);
    } else {
      if (IsolatorConfig._instance.logEvents) {
        print('${_prefixFrom(message.id)} Got a message from backend ${_withValue(message.value)}');
      }
      await responseFromBackendHandler(message);
    }
  }

  void _callbacksRunner<TVal>(_Message<TEvent, TVal?> message) {
    if (_isMessageIdHasCallbacks(message.id)) {
      if (IsolatorConfig._instance.logEvents) {
        print('${_prefixFrom(message.id)} Run callback on event');
      }
      _eventsCallbacks[message.id]!();
      _eventsCallbacks.remove(message.id);
    }
  }

  void _startChunkTransactionHandler<TVal extends Object>(_Message<TEvent, List<TVal>> message) {
    _chunksData[message.id] = message.value!;
  }

  void _addDataToChunk<TVal extends Object>(_Message<TEvent, List<TVal>> message) {
    _chunksData[message.id]!.addAll(message.value!);
  }

  _Message<TEvent, List<TVal>> _endChunkTransactionHandler<TVal extends Object>(_Message<TEvent, List<TVal>> message) {
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
    if (IsolatorConfig._instance.logEvents) {
      print('${_prefixTo(eventId)} Run backend\'s method in sync mode in frontend ${_withValue(value)}');
    }
    _toBackend.send(message);
    final TResponse result = await completer.future;
    if (IsolatorConfig._instance.logEvents) {
      print('${_prefixFrom(eventId)} Got a response from backend\'s method in sync mode in frontend ${_withValue(result)}');
    }
    return result;
  }

  Future<void> _completeSyncMessage<TVal>(_Message<TEvent, TVal?> message) async {
    final String code = message.code!;
    final Completer<dynamic>? completer = _syncResults[code];
    if (message.isErrorMessage) {
      print('${_prefixFrom(message.id)} runBackendMethod ends with error ${message.value}');
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
    if (message.isErrorMessage) {
      _errorHandler(message);
      return;
    }
    _observersHandler(message);
    if (IsolatorConfig._instance.logTimeOfDataTransfer) {
      print(
          '${_prefixFrom(message.id)} Duration of transmission of this message from backend to frontend was ${DateTime.now().difference(message.timestamp).inMicroseconds / 1000}ms');
    }

    if (message.isStartOfTransaction) {
      _startChunkTransactionHandler(message as _Message<TEvent, List<Object>>);
      return;
    } else if (message.isTransferencePieceOfTransaction) {
      _addDataToChunk(message as _Message<TEvent, List<Object>>);
      return;
    } else if (message.isEndOfTransaction) {
      final _Message<TEvent, List<Object>> chunkMessage = _endChunkTransactionHandler(message as _Message<TEvent, List<Object>>);
      _publicRunner<List<Object>>(chunkMessage);
      _callbacksRunner<List<Object>>(chunkMessage);
      return;
    }

    _publicRunner<TVal>(message);
    _callbacksRunner<TVal>(message);
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
