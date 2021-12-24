part of 'backend.dart';

@immutable
class BackendActionInitializer<Event> {
  const BackendActionInitializer({
    required Backend backend,
    required Event? event,
    required Type? eventType,
  })  : assert(event != null || eventType != null && '$eventType' != 'dynamic'),
        _backend = backend,
        _event = event,
        _eventType = eventType;

  final Backend _backend;
  final Event? _event;
  final Type? _eventType;

  void run<Request, Response>(BackendAction<Event, Request, Response> backendAction) {
    if (_event != null) {
      _backend._actions[_event!] = backendAction;
    } else {
      _checkEventRegistration(_eventType!);
      _backend._actions[_eventType!] = backendAction;
    }
  }

  void _checkEventRegistration(Type eventType) {
    for (final dynamic actionKey in _backend._actions.keys) {
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
