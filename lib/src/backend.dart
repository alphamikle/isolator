part of 'isolator.dart';

/// Class, which must be a ancestor of your backend classes
abstract class Backend<TEvent> {
  Backend(BackendArgument<void> argument)
      : _fromFront = ReceivePort(),
        _sendPortToFront = argument.toFrontend,
        _senderToFront = _Sender<TEvent, dynamic>(argument.toFrontend) {
    IsolatorConfig._instance.setParamsFromJson(argument.config);
    _fromFront.listen((dynamic val) => _messageHandler<dynamic>(val as _Message<TEvent, dynamic>));
    _sendPortToFrontend();
    _initializerCompleter = Completer();
    init();
    _checkInitialization();
  }

  final SendPort _sendPortToFront;
  final _Sender<TEvent, dynamic> _senderToFront;
  final ReceivePort _fromFront;
  final Set<String> _codes = {};
  final Set<String> _activeTransactions = {};

  /// Collection of your backend's operations, which will be executed on events from frontend
  @protected
  Map<TEvent, Function> get operations;

  bool _isInitialized = false;

  late Completer<bool> _initializerCompleter;

  /// Used for logging
  String _prefixTo(TEvent eventId) => '[Backend: $runtimeType $eventId] >>>';

  /// Used for logging
  String _prefixFrom(TEvent eventId) => '[Backend: $runtimeType $eventId] <<<';

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
  Future<void> onError(TEvent event, dynamic error) async {}

  /// Method for sending events with any data to frontend
  @protected
  void send<TVal>(TEvent eventId, [TVal? value]) {
    if (_codes.any((String code) => Utils.isCodeAndIdValid(eventId, code))) {
      throw Exception('Sync launched methods must return value, and not send event with the same id');
    }
    final _Message<TEvent, TVal?> message = _Message<TEvent, TVal?>(eventId, value: value);
    if (IsolatorConfig._instance.logEvents) {
      print('${_prefixTo(message.id)} Send message from backend to frontend');
    }
    _senderToFront.send(message);
  }

  /// Method for sending large data by chunks
  @protected
  Future<void> sendChunks<TVal>(
    TEvent eventId,
    List<TVal> values, {
    int itemsPerChunk = 100,
    Duration delay = const Duration(milliseconds: 16),
    bool updateAfterFirstChunk = false,
  }) async {
    final String eventIdString = '$eventId';
    if (_activeTransactions.any((String transactionCode) => Utils.getIdFromCode(transactionCode) == eventIdString)) {
      /// Delete code of old, now ended transaction
      final List<String> oldCodes = _activeTransactions.where((String transactionCode) => Utils.getIdFromCode(transactionCode) == eventIdString).toList();
      for (final String oldCode in oldCodes) {
        _activeTransactions.remove(oldCode);
      }
      await Future<void>.delayed(delay);
    }
    final String currentTransactionCode = Utils.generateCode(eventId);
    _activeTransactions.add(currentTransactionCode);
    _transactionRunner(eventId, values, transactionCode: currentTransactionCode, itemsPerChunk: itemsPerChunk, delay: delay, updateAfterFirstChunk: updateAfterFirstChunk);
  }

  Future<void> _transactionRunner<TVal>(
    TEvent eventId,
    List<TVal> values, {
    required String transactionCode,
    int itemsPerChunk = 100,
    Duration delay = const Duration(milliseconds: 16),
    bool updateAfterFirstChunk = false,
  }) async {
    final List<List<TVal>> chunks = [];
    List<TVal> chunk = [];
    bool isTransactionStarted = false;

    for (int i = 0; i < values.length; i++) {
      final TVal value = values[i];
      chunk.add(value);
      if (i > 0 && i % itemsPerChunk == 0) {
        chunks.add(chunk);
        chunk = [];
      }
    }
    if (chunk.isNotEmpty) {
      chunks.add(chunk);
      chunk = [];
    }

    if (chunks.isEmpty) {
      _startChunkTransaction(eventId, <TVal>[]);
      _endChunkTransaction(eventId, <TVal>[]);
    } else if (chunks.length == 1) {
      _startChunkTransaction(eventId, chunks[0]);
      _endChunkTransaction(eventId, <TVal>[]);
    } else if (chunks.length == 2) {
      _startChunkTransaction(eventId, chunks[0], updateAfterFirstChunk);
      await Future<void>.delayed(delay);
      if (!_activeTransactions.contains(transactionCode)) {
        /// This transaction was aborted
        _cancelChunkTransaction(eventId);
      }
      _endChunkTransaction(eventId, chunks[1]);
    } else {
      for (int i = 0; i < chunks.length; i++) {
        if (i > 0 && !_activeTransactions.contains(transactionCode)) {
          /// This transaction was aborted too
          _cancelChunkTransaction(eventId);
          break;
        }
        await Future<void>.delayed(delay);
        final List<TVal> chunk = chunks[i];
        final bool isLast = i == chunks.length - 1;

        if (!isTransactionStarted) {
          _startChunkTransaction(eventId, chunk, updateAfterFirstChunk);
          isTransactionStarted = true;
        } else if (!isLast) {
          _sendDataInTransaction(eventId, chunk);
        } else {
          _endChunkTransaction(eventId, chunk);
        }
      }
    }
    _activeTransactions.remove(transactionCode);
  }

  void _startChunkTransaction<TVal>(TEvent eventId, List<TVal> piece, [bool updateAfterFirstTransaction = false]) {
    final _Message<TEvent, List<TVal>> message = _Message(
      eventId,
      value: piece,
      serviceParam: updateAfterFirstTransaction ? _ServiceParam.startChunkTransactionWithUpdate : _ServiceParam.startChunkTransaction,
    );
    _senderToFront.send(message);
  }

  void _sendDataInTransaction<TVal>(TEvent eventId, List<TVal> piece) {
    final _Message<TEvent, List<TVal>> message = _Message(eventId, value: piece, serviceParam: _ServiceParam.chunkPiece);
    _senderToFront.send(message);
  }

  void _cancelChunkTransaction(TEvent eventId) {
    _senderToFront.send(_Message(eventId, serviceParam: _ServiceParam.cancelTransaction));
  }

  void _endChunkTransaction<TVal>(TEvent eventId, List<TVal> piece) {
    final _Message<TEvent, List<TVal>> message = _Message(eventId, value: piece, serviceParam: _ServiceParam.endChunkTransaction);
    _senderToFront.send(message);
  }

  void _sendSync<TVal>(TEvent eventId, TVal? value, String code, [bool isError = false]) {
    final _Message<TEvent, TVal> message = _Message<TEvent, TVal>(eventId, value: value, code: code, serviceParam: isError ? _ServiceParam.error : null);
    _senderToFront.send(message);
    _codes.remove(message.code);
  }

  void _sendError(TEvent eventId, dynamic error) {
    final _Message<TEvent, String> message = _Message<TEvent, String>(eventId, value: error.toString(), serviceParam: _ServiceParam.error);
    _senderToFront.send(message);
  }

  void _sendPortToFrontend() {
    _sendPortToFront.send(_fromFront.sendPort);
  }

  Future<void> _messageHandler<TVal>(_Message<TEvent, TVal?> message) async {
    if (IsolatorConfig._instance.logEvents) {
      print('${_prefixFrom(message.id)} Got a message from frontend');
    }

    if (IsolatorConfig._instance.logTimeOfDataTransfer) {
      print('${_prefixFrom(message.id)} Duration of transmission of this message from frontend to backend was ${DateTime.now().difference(message.timestamp).inMicroseconds / 1000}ms');
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
        result = await operation(message.value);
      } else {
        result = await operation();
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
      send<TVal>(id, result);
    }
  }
}
