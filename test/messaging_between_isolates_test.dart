import 'package:flutter_test/flutter_test.dart';

import 'isolator_test.dart';
import 'test_data/another_test_states.dart';
import 'test_data/one_test_states.dart';

Future<OneTestFrontend> createOneTestFrontend() async {
  final OneTestFrontend oneTestFrontend = OneTestFrontend();
  await oneTestFrontend.init();
  return oneTestFrontend;
}

Future<AnotherTestFrontend> createAnotherTestFrontend() async {
  final AnotherTestFrontend anotherTestFrontend = AnotherTestFrontend();
  await anotherTestFrontend.init();
  return anotherTestFrontend;
}

void main() {
  group('Group of tests for messaging between isolates', () {
    OneTestFrontend? oneTestFrontend;
    AnotherTestFrontend? anotherTestFrontend;

    setUp(() async {
      oneTestFrontend?.dispose();
      anotherTestFrontend?.dispose();
      oneTestFrontend = await createOneTestFrontend();
      anotherTestFrontend = await createAnotherTestFrontend();
    });

    test('Message from another backend to one with calling operation', () async {
      anotherTestFrontend!.callNotificationOperation();
      await wait(100);
      expect(oneTestFrontend!.value, OPERATION_VALUE);
    });

    test('Message from another backend to one with calling bus handler', () async {
      anotherTestFrontend!.callNotificationHandler();
      await wait(100);
      expect(oneTestFrontend!.value, HANDLER_VALUE + VALUE_TO_ONE_BACKEND);
    });

    test('Message from another backend to one with calling bus handler and send it back to operation', () async {
      anotherTestFrontend!.callBidirectionalNotificationHandler();
      await wait(100);
      expect(oneTestFrontend!.value, HANDLER_VALUE + BIDIRECTIONAL_VALUE);
      expect(anotherTestFrontend!.valueFromBackend, HANDLER_VALUE + BIDIRECTIONAL_VALUE);
    });

    test('Call method from one isolate in another synchronously with handler', () async {
      anotherTestFrontend!.callOneBackendHandlerMethod();
      await wait(100);
      expect(anotherTestFrontend!.valueFromBackend, SYNC_VALUE + BACK_VALUE);
    });

    test('Call method from one isolate in another synchronously with operation', () async {
      anotherTestFrontend!.callOneBackendOperationMethod();
      await wait(100);
      expect(anotherTestFrontend!.valueFromBackend, SYNC_VALUE + BACK_VALUE);
    });
  });
}
