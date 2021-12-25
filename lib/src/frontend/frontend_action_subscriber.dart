part of 'frontend.dart';

/// Helper class to help subscribe on Frontend
class FrontendActionSubscriber<Event> {
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

  FrontendEventSubscription<Event> subscribe({
    required bool single,
    required FrontendEventListener<Event> listener,
    required bool onEveryEvent,
  }) {
    final Object event = _event ?? _eventType!;
    final String code = generateSimpleRandomCode();
    final FrontendEventSubscription<Event> subscription = FrontendEventSubscription<Event>(
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
    final Set<FrontendEventSubscription>? subscriptions = _frontend._eventsSubscriptions[event];
    if (subscriptions == null) {
      throw Exception(
          'Something is wrong - you trying to close subscription $event of un nonexistent listener');
    }
    final Iterable<FrontendEventSubscription> subscriptionsWrapper =
        subscriptions.where((FrontendEventSubscription subscription) => subscription.code == code);
    if (subscriptionsWrapper.isEmpty) {
      throw Exception(
          'Something is wrong - you trying to close subscription $event of un nonexistent listener');
    }
    subscriptions
        .removeWhere((FrontendEventSubscription subscription) => subscription.code == code);
    if (subscriptions.isEmpty) {
      _frontend._eventsSubscriptions.remove(event);
    }
  }
}
