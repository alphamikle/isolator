import 'dart:isolate';

import 'package:isolator/isolator.dart';

import 'first_state.dart';

void createFirstBackend(BackendArgument<void> argument) {
  FirstBackend(argument.toFrontend);
}

class FirstBackend extends Backend<FirstEvents> {
  FirstBackend(SendPort toFrontend) : super(toFrontend);

  static const maxI = 1000 * 1000;

  int counter = 0;

  void _decrement() {
    counter--;
    send(FirstEvents.decrement, counter);
  }

  void _increment() {
    counter++;
    send(FirstEvents.increment, counter);
  }

  @override
  Map<FirstEvents, Function> get operations => {
        FirstEvents.increment: _increment,
        FirstEvents.decrement: _decrement,
      };
}
