import 'package:example/states/base_state.dart';

import 'first_backend.dart';

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
    final start = DateTime.now().microsecondsSinceEpoch;
    // await Future.wait([
    //   initBackend(createFirstBackend2),
    //   initBackend(createFirstBackend3),
    //   initBackend(createFirstBackend4),
    //   initBackend(createFirstBackend5),
    //   initBackend(createFirstBackend6),
    // ]);
    // await Future.wait([
    //   initBackend(createFirstBackend7),
    //   initBackend(createFirstBackend8),
    //   initBackend(createFirstBackend9),
    //   initBackend(createFirstBackend10),
    //   initBackend(createFirstBackend11),
    // ]);
    // await Future.wait([
    //   initBackend(createFirstBackend12),
    //   initBackend(createFirstBackend13),
    //   initBackend(createFirstBackend14),
    //   initBackend(createFirstBackend15),
    //   initBackend(createFirstBackend16),
    // ]);
    // await Future.wait([
    //   initBackend(createFirstBackend17),
    //   initBackend(createFirstBackend18),
    //   initBackend(createFirstBackend19),
    //   initBackend(createFirstBackend20),
    //   initBackend(createFirstBackend21),
    // ]);
    // await Future.wait([
    //   initBackend(createFirstBackend22),
    //   initBackend(createFirstBackend23),
    //   initBackend(createFirstBackend24),
    //   initBackend(createFirstBackend25),
    //   initBackend(createFirstBackend26),
    // ]);
    // await Future.wait([
    //   initBackend(createFirstBackend27),
    //   initBackend(createFirstBackend28),
    //   initBackend(createFirstBackend29),
    //   initBackend(createFirstBackend),
    // ]);
    await initBackend(createFirstBackend);
    print('${(DateTime.now().microsecondsSinceEpoch - start) / 1000}ms');
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
