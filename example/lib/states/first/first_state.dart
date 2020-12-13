import 'package:example/states/base_state.dart';

import 'first_backend.dart';

enum FirstEvents {
  increment,
  decrement,
  error,
}

class FirstState extends BaseState<FirstEvents> {
  int counter = 129;

  void increment() {
    send(FirstEvents.increment);
  }

  void decrement() {
    send(FirstEvents.decrement);
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
