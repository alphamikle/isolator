part of 'isolator.dart';

mixin BackendSyncMixin<TEvent> on BackendChunkMixin<TEvent> {
  final Set<String> _codes = {};

  void _sendSync<TVal>(TEvent eventId, TVal? value, String code, [bool isError = false]) {
    final _Message<TEvent, TVal> message = _Message<TEvent, TVal>(eventId, value: value, code: code, serviceParam: isError ? _ServiceParam.error : null);
    _senderToFront.send(message);
    _codes.remove(message.code);
  }
}
