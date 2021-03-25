part of 'isolator.dart';

mixin BackendOnErrorMixin<TEvent> on BackendChunkMixin<TEvent> {
  /// Hook, which will handle your backend's errors
  @protected
  Future<void> onError(TEvent event, dynamic error) async {}

  void _sendError(TEvent eventId, dynamic error) {
    final _Message<TEvent, String> message = _Message<TEvent, String>(eventId, value: error.toString(), serviceParam: _ServiceParam.error);
    _senderToFront.send(message);
  }
}
