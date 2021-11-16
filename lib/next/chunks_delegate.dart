part of 'backend/backend.dart';

@immutable
class ChunksDelegate {
  ChunksDelegate({
    required Backend backend,
  }) : _backend = backend;

  final Backend _backend;
  final Set<String> _openedTransactions = {};

  Future<void> sendChunks<Event, Data>({required Chunks<Data> chunks, required Event event, required String code, bool updateAfterFirstChunk = false}) async {
    if (_isSameTransactionExist(code)) {
      _abortTransaction(event: event, code: code);
    }
    _addTransaction(code);
    final List<Data> items = chunks.data;
    final int howMuch = chunks.size;
    await _transactionOperation(
      items: Utils.extractItemsFromList(items, howMuch),
      code: code,
      event: event,
      serviceData: ServiceData.transactionStart,
      forceUpdate: updateAfterFirstChunk,
      delay: chunks.delay,
    );
    while (items.isNotEmpty) {
      await _transactionOperation(
        items: Utils.extractItemsFromList(items, howMuch),
        code: code,
        event: event,
        serviceData: ServiceData.transactionContinue,
        forceUpdate: false,
        delay: chunks.delay,
      );
    }
    await _transactionOperation(
      items: items,
      event: event,
      code: code,
      serviceData: ServiceData.transactionEnd,
      forceUpdate: false,
      delay: chunks.delay,
    );
    _removeTransaction(code);
  }

  Future<void> _transactionOperation<Event, Data>({
    required List<Data> items,
    required Event event,
    required String code,
    required bool forceUpdate,
    required ServiceData serviceData,
    required Duration delay,
  }) async {
    _backend._sentToFrontend(
      Message(
        event: event,
        data: items,
        code: code,
        timestamp: DateTime.now(),
        serviceData: serviceData,
        forceUpdate: forceUpdate,
      ),
    );
    await Future<void>.delayed(delay);
  }

  bool _isSameTransactionExist(String code) => _openedTransactions.contains(code);

  void _abortTransaction<Event>({required Event event, required String code}) {
    _backend._sentToFrontend(
      Message(
        event: event,
        data: null,
        code: code,
        timestamp: DateTime.now(),
        serviceData: ServiceData.transactionAbort,
      ),
    );
    _removeTransaction(code);
  }

  void _removeTransaction(String code) => _openedTransactions.remove(code);

  void _addTransaction(String code) => _openedTransactions.add(code);
}
