import 'package:flutter_test/flutter_test.dart';

import 'creating_backend/frontend_example.dart';

Future<void> main() async {
  group('Creating backend', () {
    test('Check if Backend can be created', () async {
      final frontend = FrontendExample();
      await frontend.init();
      await Future<void>.delayed(const Duration(seconds: 3));
      expect(true, true);
    }, skip: true);

    test('Check running backend method', () async {
      final frontend = FrontendExample();
      await frontend.init();
      final int computeResult = await frontend.computeIntOnBackend();
      expect(computeResult, 2);
    }, skip: true);

    test('Check sending messages from backend to frontend and reversed', () async {
      final frontend = FrontendExample();
      await frontend.init();
      frontend.runBackendEventWithSendingMessageBack();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(frontend.isMessageReceived, true);
    });
  });
}
