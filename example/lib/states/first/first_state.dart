import 'package:example/states/base_state.dart';

import 'first_backend.dart';

/// Event id - you can use any of you want
enum FirstEvents {
  increment,
  decrement,
  error,
}

const bool INIT_MANY_BACKENDS = true;

class FirstState extends BaseState<FirstEvents> {
  int counter = 4699;

  void increment([int diff = 1]) {
    send(FirstEvents.increment, diff);
  }

  Future<void> decrement([int diff = 1]) async {
    counter = await runBackendMethod<int, int>(FirstEvents.decrement, diff);
  }

  void _setCounter(int value) {
    counter = value;

    /// Manual notification
    notifyListeners();
  }

  Future<void> initState() async {
    final Stopwatch stopwatch = Stopwatch();
    stopwatch.start();
    await initBackend(createFirstBackend, backendType: FirstBackend);
    stopwatch.stop();
    print('Time for initialize of 1 Backend is ${stopwatch.elapsed.inMilliseconds}ms');
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
