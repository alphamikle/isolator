# isolator

Isolator is a package, which offer to you a simple way for creating two-component states with isolated part and frontend part of any kind (BLoC, MobX, ChangeNotifier and many others).

This package is a trying to proof of concept, when you take out heavy business logic to isolates for achievement a fully cleared from any lugs application. With this package you can easy create a so-called "backend" - class with your logic and second class, which uses a special mixin - a state of any kind - BLoC / MobX / ChangeNotifier (as in an example).

## Example

Main's isolate class, who are a consumer of backend, which will be in outside isolate
```dart
/// Event id - you can use any of you want
enum FirstEvents {
  increment,
  decrement,
  error,
}

class FirstState extends BaseState<FirstEvents> {
  int counter = 209;

  void increment([int diff = 1]) {
    send(FirstEvents.increment, diff);
  }

  void decrement([int diff = 1]) {
    send(FirstEvents.decrement, diff);
  }

  void _setCounter(int value) {
    counter = value;

    /// Manual notification
    notifyListeners();
  }

  Future<void> initState() async {
    await initBackend(createFirstBackend);
  }

  /// Automatically notification after any event from backend
  @override
  void onBackendResponse() {
    notifyListeners();
  }

  @override
  Map<FirstEvents, Function> get tasks => {
    FirstEvents.increment: _setCounter,
    FirstEvents.decrement: _setCounter,
    FirstEvents.error: _setCounter,
  };
}
```
**_Backend_** - class, which will be placed at outside isolate with main business logic
```dart
void createFirstBackend(BackendArgument<void> argument) {
  FirstBackend(argument.toFrontend);
}

class FirstBackend extends Backend<FirstEvents> {
  FirstBackend(SendPort toFrontend) : super(toFrontend);

  int counter = 209;

  /// To send data back to the frontend, you can use manually method [send]
  void _decrement(int diff) {
    counter -= diff;
    send(FirstEvents.decrement, counter);
  }

  /// Or, you can simply return a value
  int _increment(int diff) {
    counter += diff;
    return counter;
  }

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