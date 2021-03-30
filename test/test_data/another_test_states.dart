import 'package:isolator/isolator.dart';

import 'one_test_states.dart';

/// Values for tests
const int VALUE_TO_ONE_BACKEND = 28;
const int BIDIRECTIONAL_VALUE = 158;
const int SYNC_VALUE = 451;

enum AnotherEvents {
  notificationOperation,
  notificationHandler,
  bidirectionalNotification,
  bidirectionalNotificationBack,
  computeHandler,
  computeOperation,
  setValue,
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

  void callOneBackendHandlerMethod() {
    send(AnotherEvents.computeHandler, SYNC_VALUE);
  }

  void callOneBackendOperationMethod() {
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

  /// Send message to different Backend with calling one of [operations] methods
  void notificationOperation() {
    sendToAnotherBackend(OneTestBackend, OneEvents.notificationOperation);
  }

  /// Send message to different Backend with calling one of [busHandlers] methods
  void notificationHandler() {
    sendToAnotherBackend(OneTestBackend, OneEvents.notificationHandler, VALUE_TO_ONE_BACKEND);
  }

  /// Send message to different Backend and getting message back
  void bidirectionalNotification(int value) {
    sendToAnotherBackend(OneTestBackend, OneEvents.bidirectional, value);
  }

  /// Getting message back from different Backend
  void bidirectionalNotificationBack(int value) {
    send(AnotherEvents.setValue, value);
  }

  /// Call one of [busHandlers] methods of different backend in synchronous style
  Future<void> callOneBackendHandlerMethod(int value) async {
    final int valueFromOneBackend = await runAnotherBackendMethod(OneTestBackend, OneEvents.computeValue, value);
    send(AnotherEvents.setValue, valueFromOneBackend);
  }

  /// Call one of [operations] methods of different backend in synchronous style
  Future<void> callOneBackendOperationMethod(int value) async {
    final int valueFromOneBackend = await runAnotherBackendMethod(OneTestBackend, OneEvents.computeValueOperation, value);
    send(AnotherEvents.setValue, valueFromOneBackend);
  }

  @override
  Map<AnotherEvents, Function> get operations {
    return {
      AnotherEvents.notificationOperation: notificationOperation,
      AnotherEvents.notificationHandler: notificationHandler,
      AnotherEvents.bidirectionalNotification: bidirectionalNotification,
      AnotherEvents.bidirectionalNotificationBack: bidirectionalNotificationBack,
      AnotherEvents.computeHandler: callOneBackendHandlerMethod,
      AnotherEvents.computeOperation: callOneBackendOperationMethod,
    };
  }
}

void createAnotherBackend(BackendArgument<void> argument) {
  AnotherTestBackend(argument);
}
