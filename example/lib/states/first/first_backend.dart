import 'dart:math';

import 'package:example/states/second/second_backend_interactor.dart';
import 'package:isolator/isolator.dart';

import 'first_state.dart';

void createFirstBackend(BackendArgument<void> argument) {
  FirstBackend(argument);
}

enum MessageBus {
  increment,
  computeValue,
}

class FirstBackend extends Backend<FirstEvents> {
  FirstBackend(BackendArgument<void> argument) : super(argument);

  SecondBackendInteractor get _secondBackendInteractor => SecondBackendInteractor(this);

  int counter = 4699;

  /// Or, you can simply return a value
  Future<int> _decrement(int diff) async {
    counter -= diff;
    return counter;
  }

  /// To send data back to the frontend, you can use manually method [send]
  Future<void> _increment(int diff) async {
    counter += diff;
    _secondBackendInteractor.sendIncrementEvent(counter);
    send(FirstEvents.increment, counter);
  }

  void _handleResponseFromSecondBackend(int value) {
    counter = Random().nextInt(1500);
    send(FirstEvents.increment, counter);
  }

  @override
  Map<FirstEvents, Function> get operations => {
        FirstEvents.increment: _increment,
        FirstEvents.decrement: _decrement,
      };

  @override
  Map<dynamic, Function> get busHandlers {
    return <dynamic, Function>{
      MessageBus.increment: _handleResponseFromSecondBackend,
    };
  }
}
