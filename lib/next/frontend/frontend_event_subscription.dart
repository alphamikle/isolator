import 'package:flutter/cupertino.dart';
import 'package:isolator/next/types.dart';

class FrontendEventSubscription<Event> {
  FrontendEventSubscription({
    required VoidCallback onClose,
    required FrontendEventListener<Event> listener,
    required bool single,
    required this.code,
  })  : _onClose = onClose,
        _single = single,
        _listener = listener;

  bool _isClosed = false;
  final bool _single;
  final VoidCallback _onClose;
  final String code;
  final FrontendEventListener<Event> _listener;
  bool get isClosed => _isClosed;

  void run(Event event) {
    if (_isClosed) {
      throw Exception('FrontendEventListener<$Event> was closed previously');
    }
    _listener(event);
    if (_single) {
      close();
    }
  }

  void close() {
    if (_isClosed) {
      throw Exception('FrontendEventListener<$Event> was closed previously');
    }
    _isClosed = true;
    _onClose();
  }
}
