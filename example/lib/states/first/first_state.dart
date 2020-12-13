import 'package:example/states/base_state.dart';

import 'first_backend.dart';

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
