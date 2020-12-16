import 'dart:isolate';

import 'package:isolator/isolator.dart';

import 'first_state.dart';

void createFirstBackend(BackendArgument<void> argument) {
  FirstBackend(argument.toFrontend);
}

class FirstBackend extends Backend<FirstEvents> {
  FirstBackend(SendPort toFrontend) : super(toFrontend);

  int counter = 4699;

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

/// For tests how is maximum isolates can have app without lugs

void createFirstBackend2(BackendArgument<void> argument) {
  FirstBackend2(argument.toFrontend);
}

void createFirstBackend3(BackendArgument<void> argument) {
  FirstBackend3(argument.toFrontend);
}

void createFirstBackend4(BackendArgument<void> argument) {
  FirstBackend4(argument.toFrontend);
}

void createFirstBackend5(BackendArgument<void> argument) {
  FirstBackend5(argument.toFrontend);
}

void createFirstBackend6(BackendArgument<void> argument) {
  FirstBackend6(argument.toFrontend);
}

void createFirstBackend7(BackendArgument<void> argument) {
  FirstBackend7(argument.toFrontend);
}

void createFirstBackend8(BackendArgument<void> argument) {
  FirstBackend8(argument.toFrontend);
}

void createFirstBackend9(BackendArgument<void> argument) {
  FirstBackend9(argument.toFrontend);
}

void createFirstBackend10(BackendArgument<void> argument) {
  FirstBackend10(argument.toFrontend);
}

void createFirstBackend11(BackendArgument<void> argument) {
  FirstBackend11(argument.toFrontend);
}

void createFirstBackend12(BackendArgument<void> argument) {
  FirstBackend12(argument.toFrontend);
}

void createFirstBackend13(BackendArgument<void> argument) {
  FirstBackend13(argument.toFrontend);
}

void createFirstBackend14(BackendArgument<void> argument) {
  FirstBackend14(argument.toFrontend);
}

void createFirstBackend15(BackendArgument<void> argument) {
  FirstBackend15(argument.toFrontend);
}

void createFirstBackend16(BackendArgument<void> argument) {
  FirstBackend16(argument.toFrontend);
}

void createFirstBackend17(BackendArgument<void> argument) {
  FirstBackend17(argument.toFrontend);
}

void createFirstBackend18(BackendArgument<void> argument) {
  FirstBackend18(argument.toFrontend);
}

void createFirstBackend19(BackendArgument<void> argument) {
  FirstBackend19(argument.toFrontend);
}

void createFirstBackend20(BackendArgument<void> argument) {
  FirstBackend20(argument.toFrontend);
}

void createFirstBackend21(BackendArgument<void> argument) {
  FirstBackend21(argument.toFrontend);
}

void createFirstBackend22(BackendArgument<void> argument) {
  FirstBackend22(argument.toFrontend);
}

void createFirstBackend23(BackendArgument<void> argument) {
  FirstBackend23(argument.toFrontend);
}

void createFirstBackend24(BackendArgument<void> argument) {
  FirstBackend24(argument.toFrontend);
}

void createFirstBackend25(BackendArgument<void> argument) {
  FirstBackend25(argument.toFrontend);
}

void createFirstBackend26(BackendArgument<void> argument) {
  FirstBackend26(argument.toFrontend);
}

void createFirstBackend27(BackendArgument<void> argument) {
  FirstBackend27(argument.toFrontend);
}

void createFirstBackend28(BackendArgument<void> argument) {
  FirstBackend28(argument.toFrontend);
}

void createFirstBackend29(BackendArgument<void> argument) {
  FirstBackend29(argument.toFrontend);
}

class FirstBackend2 extends FirstBackend {
  FirstBackend2(SendPort toFrontend) : super(toFrontend);
}

class FirstBackend3 extends FirstBackend {
  FirstBackend3(SendPort toFrontend) : super(toFrontend);
}

class FirstBackend4 extends FirstBackend {
  FirstBackend4(SendPort toFrontend) : super(toFrontend);
}

class FirstBackend5 extends FirstBackend {
  FirstBackend5(SendPort toFrontend) : super(toFrontend);
}

class FirstBackend6 extends FirstBackend {
  FirstBackend6(SendPort toFrontend) : super(toFrontend);
}

class FirstBackend7 extends FirstBackend {
  FirstBackend7(SendPort toFrontend) : super(toFrontend);
}

class FirstBackend8 extends FirstBackend {
  FirstBackend8(SendPort toFrontend) : super(toFrontend);
}

class FirstBackend9 extends FirstBackend {
  FirstBackend9(SendPort toFrontend) : super(toFrontend);
}

class FirstBackend10 extends FirstBackend {
  FirstBackend10(SendPort toFrontend) : super(toFrontend);
}

class FirstBackend11 extends FirstBackend {
  FirstBackend11(SendPort toFrontend) : super(toFrontend);
}

class FirstBackend12 extends FirstBackend {
  FirstBackend12(SendPort toFrontend) : super(toFrontend);
}

class FirstBackend13 extends FirstBackend {
  FirstBackend13(SendPort toFrontend) : super(toFrontend);
}

class FirstBackend14 extends FirstBackend {
  FirstBackend14(SendPort toFrontend) : super(toFrontend);
}

class FirstBackend15 extends FirstBackend {
  FirstBackend15(SendPort toFrontend) : super(toFrontend);
}

class FirstBackend16 extends FirstBackend {
  FirstBackend16(SendPort toFrontend) : super(toFrontend);
}

class FirstBackend17 extends FirstBackend {
  FirstBackend17(SendPort toFrontend) : super(toFrontend);
}

class FirstBackend18 extends FirstBackend {
  FirstBackend18(SendPort toFrontend) : super(toFrontend);
}

class FirstBackend19 extends FirstBackend {
  FirstBackend19(SendPort toFrontend) : super(toFrontend);
}

class FirstBackend20 extends FirstBackend {
  FirstBackend20(SendPort toFrontend) : super(toFrontend);
}

class FirstBackend21 extends FirstBackend {
  FirstBackend21(SendPort toFrontend) : super(toFrontend);
}

class FirstBackend22 extends FirstBackend {
  FirstBackend22(SendPort toFrontend) : super(toFrontend);
}

class FirstBackend23 extends FirstBackend {
  FirstBackend23(SendPort toFrontend) : super(toFrontend);
}

class FirstBackend24 extends FirstBackend {
  FirstBackend24(SendPort toFrontend) : super(toFrontend);
}

class FirstBackend25 extends FirstBackend {
  FirstBackend25(SendPort toFrontend) : super(toFrontend);
}

class FirstBackend26 extends FirstBackend {
  FirstBackend26(SendPort toFrontend) : super(toFrontend);
}

class FirstBackend27 extends FirstBackend {
  FirstBackend27(SendPort toFrontend) : super(toFrontend);
}

class FirstBackend28 extends FirstBackend {
  FirstBackend28(SendPort toFrontend) : super(toFrontend);
}

class FirstBackend29 extends FirstBackend {
  FirstBackend29(SendPort toFrontend) : super(toFrontend);
}
