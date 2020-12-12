import 'package:flutter/widgets.dart';
import 'package:isolator/isolator.dart';

import 'first_backend.dart';

enum FirstEvents {
  increment,
  decrement,
  error,
}

class FirstState with ChangeNotifier, BackendMixin<FirstEvents> {
  int counter = 0;
  bool isComputing = false;

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
