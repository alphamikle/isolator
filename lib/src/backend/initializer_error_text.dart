library isolator;

/// Helper for inner layer of the package
String initializerErrorText({
  required dynamic actionKey,
  required dynamic eventType,
}) =>
    '''
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
}''';
