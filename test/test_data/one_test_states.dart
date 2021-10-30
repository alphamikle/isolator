import 'package:isolator/isolator.dart';

import 'another_test_states.dart';

/// Values for tests
const int OPERATION_VALUE = 89;
const int HANDLER_VALUE = 63;
const int BACK_VALUE = 812;

enum OneEvents {
  setValue,
  notificationOperation,
  notificationHandler,
  bidirectional,
  computeValue,
  computeValueOperation,
}

class OneTestFrontend with Frontend<OneEvents> {
  int value = 0;

  void setValue(int newValue) {
    value = newValue;
  }

  Future<void> init() async {
    await initBackend(createOneBackend, backendType: OneTestBackend);
  }

  void dispose() {
    killBackend();
  }

  @override
  Map<OneEvents, Function> get tasks {
    return {
      OneEvents.setValue: setValue,
    };
  }
}

class OneTestBackend extends Backend<OneEvents> {
  OneTestBackend(BackendArgument<void> argument) : super(argument);

  AnotherTestBackendInteractor get _anotherTestBackendInteractor => AnotherTestBackendInteractor(this);

  void _setValueWithOperation() {
    send(OneEvents.setValue, OPERATION_VALUE);
  }

  void _setValueWithHandler(int value) {
    send(OneEvents.setValue, HANDLER_VALUE + value);
  }

  void _setValueWithHandlerAndSendItBack(int value) {
    send(OneEvents.setValue, HANDLER_VALUE + value);
    _anotherTestBackendInteractor.callBidirectionalNotificationBackMethod(HANDLER_VALUE + value);
  }

  int _returnBackValue(int value) {
    return BACK_VALUE + value;
  }

  @override
  Map<OneEvents, Function> get operations {
    return {
      OneEvents.notificationOperation: _setValueWithOperation,
      OneEvents.computeValueOperation: _returnBackValue,
    };
  }

  /// [busHandlers] are similar to [operations], but have any type of key and was made for
  /// being called from another isolates BUT
  /// also, you can call operation from different isolates too
  @override
  Map<dynamic, Function> get busHandlers {
    return <dynamic, Function>{
      OneEvents.notificationHandler: _setValueWithHandler,
      OneEvents.bidirectional: _setValueWithHandlerAndSendItBack,
      OneEvents.computeValue: _returnBackValue,
    };
  }
}

class OneTestBackendInteractor extends InteractorOf<OneTestBackend> {
  OneTestBackendInteractor(Backend backend) : super(backend);

  void callNotificationOperationMethod() {
    sendMessage(OneEvents.notificationOperation);
  }

  void callNotificationHandlerMethod() {
    sendMessage(OneEvents.notificationHandler, VALUE_TO_ONE_BACKEND);
  }

  void callBidirectionalNotificationMethod(int value) {
    sendMessage(OneEvents.bidirectional, value);
  }

  Future<int> callComputeHandlerMethod(int value) async {
    final int currentValue = await runMethod(OneEvents.computeValue, value);
    return currentValue;
  }

  Future<int> callComputeOperationMethod(int value) async {
    final int currentValue = await runMethod(OneEvents.computeValueOperation, value);
    return currentValue;
  }
}

void createOneBackend(BackendArgument<void> argument) {
  OneTestBackend(argument);
}
