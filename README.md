# isolator

Isolator is a package, which offer to you a simple way for creating two-component states with isolated part and frontend part of any kind (BLoC, MobX, ChangeNotifier and many others).

This package is a trying to proof of concept, when you take out heavy business logic to isolates for achievement a fully cleared from any lugs application. With this package you can easy create a so-called "backend" - class with your logic and second class, which uses a special mixin - a state of any kind - BLoC / MobX / ChangeNotifier (as in an example).

## Example

Main's isolate class, who are a consumer of backend - it has a name **Frontend**, or Frontend<EventType>
```dart
/// Event id - you can use any of you want
enum FirstEvents {
  increment,
  decrement,
  error,
}

class FirstState with Frontend<FirstEvents>, ChangeNotifier {
  int counter = 209;

  void increment([int diff = 1]) {
    send(FirstEvents.increment, diff);
  }

  /// You can run any backend method in synchronous mode with method [runBackendMethod] of Frontend
  Future<void> decrement([int diff = 1]) async {
    counter = await runBackendMethod(FirstEvents.decrement, diff);
  }

  void _setCounter(int value) {
    counter = value;

    /// Manual notification
    notifyListeners();
  }

  Future<void> initState() async {
    /// [initBackend] method of Frontend used for creating a Backend instance in isolate
    /// creating function should write manually, example is below
    /// [data] and [errorHandler] is a optional fields for initialization of isolates
    await initBackend(createFirstBackend, data: data, errorHandler: errorHandler);
  }

  /// Hook, which calling after every message from backend of this state
  @override
  void onBackendResponse() {
    notifyListeners();
  }

  /// [tasks] - it is a getter, which return pairs of Event and Function, which called automatically on correspond Message from Backend
  @override
  Map<FirstEvents, Function> get tasks => {
    FirstEvents.increment: _setCounter,
    FirstEvents.decrement: _setCounter,
    FirstEvents.error: _setCounter,
  };
}
```
**Backend** - class, which will be placed at outside isolate with main business logic
```dart
/// Function, which was written by hand
void createFirstBackend(BackendArgument<void> argument) {
  FirstBackend(argument);
}

class FirstBackend extends Backend<FirstEvents> {
  FirstBackend(BackendArgument<void> argument) : super(argument);

  int counter = 209;

  /// To send data back to the frontend, you can use manually method [send]
  void _increment(int diff) {
    counter += diff;
    send(FirstEvents.increment, counter);
  }

  /// Or, you can simply return a value
  /// If you have a plans to running methods of Backend in synchronous mode - then, this methods must always return a value
  /// but this methods still have possibility to send others messages with events before return a value
  int _decrement(int diff) {
    counter -= diff;
    return counter;
  }

  /// [operations] - it is a getter, which return pairs of Event and Function, which called automatically on correspond Message from Frontend
  @override
  Map<FirstEvents, Function> get operations => {
    FirstEvents.increment: _increment,
    FirstEvents.decrement: _decrement,
  };
}
```

## Restrictions
- Backend classes can't use a native layer (method-channel)
- For one backend - one isolate (too many isolates take much time for initialization, for example: ~6000ms for 30 isolates at emulator in dev mode) 

## Schema of interaction

![Schema](https://github.com/alphamikle/isolator/raw/master/schema.png)