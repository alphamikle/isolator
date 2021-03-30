import 'package:isolator/isolator.dart';

import 'one_test_states.dart';

enum AnotherEvents {
  notificationOperation,
  notificationHandler,
  bidirectionalNotification,
  bidirectionalNotificationBack,
  computeOperation,
  setValue,
}

const int VALUE_TO_ONE_BACKEND = 28;
const int BIDIRECTIONAL_VALUE = 158;
const int SYNC_VALUE = 451;

void pad(int value) {
  final String string = ''.padLeft(50, ':') + value.toString();
  print(string);
}

class AnotherTestFrontend with Frontend<AnotherEvents> {
  int valueFromBackend = 0;

  void _setValue(int value) {
    valueFromBackend = value;
  }

  void callNotificationOperation() {
    send(AnotherEvents.notificationOperation);
  }

  void callNotificationHandler() {
    send(AnotherEvents.notificationHandler);
  }

  void callBidirectionalNotificationHandler() {
    send(AnotherEvents.bidirectionalNotification, BIDIRECTIONAL_VALUE);
  }

  void callOneBackendMethod() {
    send(AnotherEvents.computeOperation, SYNC_VALUE);
  }

  Future<void> init() async {
    await initBackend(createAnotherBackend, backendType: AnotherTestBackend);
  }

  void dispose() {
    killBackend();
  }

  @override
  Map<AnotherEvents, Function> get tasks {
    return {
      AnotherEvents.setValue: _setValue,
    };
  }
}

class AnotherTestBackend extends Backend<AnotherEvents> {
  AnotherTestBackend(BackendArgument<void> argument) : super(argument);

  void notificationOperation() {
    sendToAnotherBackend(OneTestBackend, OneEvents.notificationOperation);
  }

  void notificationHandler() {
    sendToAnotherBackend(OneTestBackend, OneEvents.notificationHandler, VALUE_TO_ONE_BACKEND);
  }

  void bidirectionalNotification(int value) {
    sendToAnotherBackend(OneTestBackend, OneEvents.bidirectional, value);
  }

  void bidirectionalNotificationBack(int value) {
    send(AnotherEvents.setValue, value);
  }

  Future<void> callOneBackendMethod(int value) async {
    final int valueFromOneBackend = await runAnotherBackendMethod(OneTestBackend, OneEvents.computeValue, value);
    send(AnotherEvents.setValue, valueFromOneBackend);
  }

  @override
  Map<AnotherEvents, Function> get operations {
    return {
      AnotherEvents.notificationOperation: notificationOperation,
      AnotherEvents.notificationHandler: notificationHandler,
      AnotherEvents.bidirectionalNotification: bidirectionalNotification,
      AnotherEvents.bidirectionalNotificationBack: bidirectionalNotificationBack,
      AnotherEvents.computeOperation: callOneBackendMethod,
    };
  }
}

void createAnotherBackend(BackendArgument<void> argument) {
  AnotherTestBackend(argument);
}
