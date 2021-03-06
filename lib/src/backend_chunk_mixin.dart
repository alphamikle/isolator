part of 'isolator.dart';

mixin BackendChunkMixin<TEvent> {
  late _Sender<TEvent, dynamic> _senderToFront;
  final Set<String> _activeTransactions = {};

  /// Method for sending large data by chunks
  @protected
  Future<void> sendChunks<TVal>(TEvent eventId, List<TVal> values, {int itemsPerChunk = 100, Duration delay = const Duration(milliseconds: 16), bool updateAfterFirstChunk = false}) async {
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

  Future<void> _transactionRunner<TVal>(TEvent eventId, List<TVal> values,
      {required String transactionCode, int itemsPerChunk = 100, Duration delay = const Duration(milliseconds: 16), bool updateAfterFirstChunk = false}) async {
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
}
