part of 'frontend.dart';

class FrontendActionInitializer<Event> {
  FrontendActionInitializer({
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

  void run<Request, Response>(FrontendAction<Event, Request, Response> frontendAction) {
    if (_event != null) {
      _frontend._actions[_event!] = frontendAction;
    } else {
      _checkEventRegistration(_eventType!);
      _frontend._actions[_eventType!] = frontendAction;
    }
  }

  void _checkEventRegistration(Type eventType) {
    for (final dynamic actionKey in _frontend._actions.keys) {
      final String keyType = actionKey.runtimeType.toString();
      if (keyType == '$Type') {
        continue;
      }
      if (eventType.toString() == keyType) {
        throw Exception(initializerErrorText(actionKey: actionKey, eventType: eventType));
      }
    }
  }
}
