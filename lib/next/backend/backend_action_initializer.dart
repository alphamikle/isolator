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
        throw Exception('''
Events types collision:
Registered type: $actionKey
Trying to register: $eventType

---

You can register event of one type only as a typed action:
void initActions() {
  on<SomeType>().run(yourAction);
}

or as valued action:
void initActions() {
  on(SomeType()).run(yourAction);
}

---

Typed actions preferable if you want to contains some params in your events directly and want to handle them, like this:

// Backend:
void initActions() {
  on<SomeParam>().run(yourAction);
}

// Frontend:
Future<int> someFrontendMethod() async {
  final backendResult = run(event: SomeType(someParam: 12312341));
}

---

And Valued actions preferable if you will use simple events, like enums:

// Backend:
void initActions() {
  on(MyEvents.someEvent).run(yourAction);
}

// Frontend:
Future<int> someFrontendMethod() async {
  final backendResult = run(event: MyEvents.someEvent);
}''');
      }
    }
  }
}
