import 'package:isolator/isolator.dart';

import 'first_state.dart';

void createFirstBackend(BackendArgument<void> argument) {
  FirstBackend(argument);
}

class FirstBackend extends Backend<FirstEvents> {
  FirstBackend(BackendArgument<void> argument) : super(argument);

  int counter = 4699;

  /// Or, you can simply return a value
  Future<int> _decrement(int diff) async {
    counter -= diff;
    return counter;
  }

  /// To send data back to the frontend, you can use manually method [send]
  void _increment(int diff) {
    counter += diff;
    send(FirstEvents.increment, counter);
  }

  @override
  Map<FirstEvents, Function> get operations => {
        FirstEvents.increment: _increment,
        FirstEvents.decrement: _decrement,
      };
}

/// For tests how is maximum isolates can have app without lugs

void createFirstBackend2(BackendArgument<void> argument) {
  FirstBackend2(argument);
}

void createFirstBackend3(BackendArgument<void> argument) {
  FirstBackend3(argument);
}

void createFirstBackend4(BackendArgument<void> argument) {
  FirstBackend4(argument);
}

void createFirstBackend5(BackendArgument<void> argument) {
  FirstBackend5(argument);
}

void createFirstBackend6(BackendArgument<void> argument) {
  FirstBackend6(argument);
}

void createFirstBackend7(BackendArgument<void> argument) {
  FirstBackend7(argument);
}

void createFirstBackend8(BackendArgument<void> argument) {
  FirstBackend8(argument);
}

void createFirstBackend9(BackendArgument<void> argument) {
  FirstBackend9(argument);
}

void createFirstBackend10(BackendArgument<void> argument) {
  FirstBackend10(argument);
}

void createFirstBackend11(BackendArgument<void> argument) {
  FirstBackend11(argument);
}

void createFirstBackend12(BackendArgument<void> argument) {
  FirstBackend12(argument);
}

void createFirstBackend13(BackendArgument<void> argument) {
  FirstBackend13(argument);
}

void createFirstBackend14(BackendArgument<void> argument) {
  FirstBackend14(argument);
}

void createFirstBackend15(BackendArgument<void> argument) {
  FirstBackend15(argument);
}

void createFirstBackend16(BackendArgument<void> argument) {
  FirstBackend16(argument);
}

void createFirstBackend17(BackendArgument<void> argument) {
  FirstBackend17(argument);
}

void createFirstBackend18(BackendArgument<void> argument) {
  FirstBackend18(argument);
}

void createFirstBackend19(BackendArgument<void> argument) {
  FirstBackend19(argument);
}

void createFirstBackend20(BackendArgument<void> argument) {
  FirstBackend20(argument);
}

void createFirstBackend21(BackendArgument<void> argument) {
  FirstBackend21(argument);
}

void createFirstBackend22(BackendArgument<void> argument) {
  FirstBackend22(argument);
}

void createFirstBackend23(BackendArgument<void> argument) {
  FirstBackend23(argument);
}

void createFirstBackend24(BackendArgument<void> argument) {
  FirstBackend24(argument);
}

void createFirstBackend25(BackendArgument<void> argument) {
  FirstBackend25(argument);
}

void createFirstBackend26(BackendArgument<void> argument) {
  FirstBackend26(argument);
}

void createFirstBackend27(BackendArgument<void> argument) {
  FirstBackend27(argument);
}

void createFirstBackend28(BackendArgument<void> argument) {
  FirstBackend28(argument);
}

void createFirstBackend29(BackendArgument<void> argument) {
  FirstBackend29(argument);
}

class FirstBackend2 extends FirstBackend {
  FirstBackend2(BackendArgument<void> argument) : super(argument);
}

class FirstBackend3 extends FirstBackend {
  FirstBackend3(BackendArgument<void> argument) : super(argument);
}

class FirstBackend4 extends FirstBackend {
  FirstBackend4(BackendArgument<void> argument) : super(argument);
}

class FirstBackend5 extends FirstBackend {
  FirstBackend5(BackendArgument<void> argument) : super(argument);
}

class FirstBackend6 extends FirstBackend {
  FirstBackend6(BackendArgument<void> argument) : super(argument);
}

class FirstBackend7 extends FirstBackend {
  FirstBackend7(BackendArgument<void> argument) : super(argument);
}

class FirstBackend8 extends FirstBackend {
  FirstBackend8(BackendArgument<void> argument) : super(argument);
}

class FirstBackend9 extends FirstBackend {
  FirstBackend9(BackendArgument<void> argument) : super(argument);
}

class FirstBackend10 extends FirstBackend {
  FirstBackend10(BackendArgument<void> argument) : super(argument);
}

class FirstBackend11 extends FirstBackend {
  FirstBackend11(BackendArgument<void> argument) : super(argument);
}

class FirstBackend12 extends FirstBackend {
  FirstBackend12(BackendArgument<void> argument) : super(argument);
}

class FirstBackend13 extends FirstBackend {
  FirstBackend13(BackendArgument<void> argument) : super(argument);
}

class FirstBackend14 extends FirstBackend {
  FirstBackend14(BackendArgument<void> argument) : super(argument);
}

class FirstBackend15 extends FirstBackend {
  FirstBackend15(BackendArgument<void> argument) : super(argument);
}

class FirstBackend16 extends FirstBackend {
  FirstBackend16(BackendArgument<void> argument) : super(argument);
}

class FirstBackend17 extends FirstBackend {
  FirstBackend17(BackendArgument<void> argument) : super(argument);
}

class FirstBackend18 extends FirstBackend {
  FirstBackend18(BackendArgument<void> argument) : super(argument);
}

class FirstBackend19 extends FirstBackend {
  FirstBackend19(BackendArgument<void> argument) : super(argument);
}

class FirstBackend20 extends FirstBackend {
  FirstBackend20(BackendArgument<void> argument) : super(argument);
}

class FirstBackend21 extends FirstBackend {
  FirstBackend21(BackendArgument<void> argument) : super(argument);
}

class FirstBackend22 extends FirstBackend {
  FirstBackend22(BackendArgument<void> argument) : super(argument);
}

class FirstBackend23 extends FirstBackend {
  FirstBackend23(BackendArgument<void> argument) : super(argument);
}

class FirstBackend24 extends FirstBackend {
  FirstBackend24(BackendArgument<void> argument) : super(argument);
}

class FirstBackend25 extends FirstBackend {
  FirstBackend25(BackendArgument<void> argument) : super(argument);
}

class FirstBackend26 extends FirstBackend {
  FirstBackend26(BackendArgument<void> argument) : super(argument);
}

class FirstBackend27 extends FirstBackend {
  FirstBackend27(BackendArgument<void> argument) : super(argument);
}

class FirstBackend28 extends FirstBackend {
  FirstBackend28(BackendArgument<void> argument) : super(argument);
}

class FirstBackend29 extends FirstBackend {
  FirstBackend29(BackendArgument<void> argument) : super(argument);
}
