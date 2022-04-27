library isolator;

import 'dart:async';

import 'package:isolator/src/frontend/frontend.dart';
import 'package:isolator/src/types.dart';

/// Class
class FrontendEventSubscription<Event> {
  /// This class holds information about your [Frontend]'s subscription
  /// and helps you to close corresponding subscription
  FrontendEventSubscription({
    required Callback onClose,
    required FrontendEventListener<Event> listener,
    required bool single,
    required this.code,
  })  : _onClose = onClose,
        _single = single,
        _listener = listener;

  bool _isClosed = false;
  final bool _single;
  final Callback _onClose;

  /// Code to identify the subscription
  final String code;
  final FrontendEventListener<Event> _listener;

  /// Show you if this subscription is closed and if - this subscription can't
  /// be started anymore
  bool get isClosed => _isClosed;

  /// With this method package will run callback of this subscription
  void run(Event event) {
    if (_isClosed) {
      throw Exception('FrontendEventListener<$Event> was closed previously');
    }
    _listener(event);
    if (_single) {
      close();
    }
  }

  /// Method for close the subscription (as in the [StreamSubscription])
  void close() {
    if (_isClosed) {
      throw Exception('FrontendEventListener<$Event> was closed previously');
    }
    _isClosed = true;
    _onClose();
  }
}
