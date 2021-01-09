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
    const int howMuch = 3;
    if (INIT_MANY_BACKENDS) {
      /// For big numbers need more RAM on device or emulator
      /// for example 2048mb of emulator not enough in my case for passing number 4
      await _initManyBackends(initBackend, howMuch);
    }
    await initBackend(createFirstBackend);
    stopwatch.stop();
    print('Time for initialize of ${INIT_MANY_BACKENDS ? '${howMuch * 5} Backends' : '1 Backend'} is ${stopwatch.elapsed.inMilliseconds}ms');
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

Future<void> _initManyBackends(Function initBackend, int howMuch) async {
  assert(howMuch >= 0 && howMuch <= 6);
  List<Future<dynamic>> chunk() => <Future<dynamic>>[
        initBackend(createFirstBackend2),
        initBackend(createFirstBackend3),
        initBackend(createFirstBackend4),
        initBackend(createFirstBackend5),
        initBackend(createFirstBackend6),
      ];
  List<Future<dynamic>> chunk2() => <Future<dynamic>>[
        initBackend(createFirstBackend7),
        initBackend(createFirstBackend8),
        initBackend(createFirstBackend9),
        initBackend(createFirstBackend10),
        initBackend(createFirstBackend11),
      ];
  List<Future<dynamic>> chunk3() => <Future<dynamic>>[
        initBackend(createFirstBackend12),
        initBackend(createFirstBackend13),
        initBackend(createFirstBackend14),
        initBackend(createFirstBackend15),
        initBackend(createFirstBackend16),
      ];
  List<Future<dynamic>> chunk4() => <Future<dynamic>>[
        initBackend(createFirstBackend17),
        initBackend(createFirstBackend18),
        initBackend(createFirstBackend19),
        initBackend(createFirstBackend20),
        initBackend(createFirstBackend21),
      ];
  List<Future<dynamic>> chunk5() => <Future<dynamic>>[
        initBackend(createFirstBackend22),
        initBackend(createFirstBackend23),
        initBackend(createFirstBackend24),
        initBackend(createFirstBackend25),
        initBackend(createFirstBackend26),
      ];
  List<Future<dynamic>> chunk6() => <Future<dynamic>>[
        initBackend(createFirstBackend27),
        initBackend(createFirstBackend28),
        initBackend(createFirstBackend29),
        initBackend(createFirstBackend),
      ];
  final List<Function> chunksCreators = <Function>[
    chunk6,
    chunk,
    chunk2,
    chunk3,
    chunk4,
    chunk5,
  ];
  for (int i = 1; i <= howMuch; i++) {
    await Future.wait<dynamic>(chunksCreators[i - 1]());
  }
}
