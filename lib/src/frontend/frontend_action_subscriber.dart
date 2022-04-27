part of 'frontend.dart';

/// Class
class FrontendActionSubscriber<Event> {
  /// Helper class to help subscribe on Frontend
  FrontendActionSubscriber({
    required Frontend frontend,
    required Event? event,
    required Type? eventType,
  })  : assert(event != null || eventType != null && '$eventType' != 'dynamic'),
        _frontend = frontend,
        _event = event,
        _eventType = eventType;

  final Frontend _frontend;
  final Event? _event;
  final Type? _eventType;

  /// With this method you will subscribe on [Frontend] events
  FrontendEventSubscription<Event> subscribe({
    required bool single,
    required FrontendEventListener<Event> listener,
    required bool onEveryEvent,
  }) {
    final event = _event ?? _eventType!;
    final code = generateSimpleRandomCode();
    final subscription = FrontendEventSubscription<Event>(
      onClose: () => _close(event, listener, code),
      single: single,
      code: code,
      listener: listener,
    );
    if (_frontend._eventsSubscriptions.containsKey(event)) {
      _frontend._eventsSubscriptions[event]!.add(subscription);
    } else {
      _frontend._eventsSubscriptions[event] = {subscription};
    }
    return subscription;
  }

  void _close(dynamic event, Function listener, String code) {
    final subscriptions = _frontend._eventsSubscriptions[event];
    if (subscriptions == null) {
      throw Exception('''
[isolator]
Something is wrong - you trying to close subscription $event of nonexistent listener
''');
    }
    final subscriptionsWrapper = subscriptions.where(
      (FrontendEventSubscription subscription) => subscription.code == code,
    );
    if (subscriptionsWrapper.isEmpty) {
      throw Exception('''
[isolator]
Something is wrong - you trying to close subscription $event of nonexistent listener
''');
    }
    subscriptions.removeWhere(
      (FrontendEventSubscription subscription) => subscription.code == code,
    );
    if (subscriptions.isEmpty) {
      _frontend._eventsSubscriptions.remove(event);
    }
  }
}
