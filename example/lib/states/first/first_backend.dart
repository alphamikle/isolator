import 'dart:isolate';

import 'package:isolator/isolator.dart';

import 'first_state.dart';

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
