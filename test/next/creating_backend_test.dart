import 'package:flutter_test/flutter_test.dart';

import 'creating_backend/backend_example.dart';
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
    }, skip: true);

    test('Check sending large amount of data via chunks from Backend to Frontend with "send" method', () async {
      final frontend = FrontendExample();
      await frontend.init();
      frontend.initReceivingMockData();
      await Future<void>.delayed(const Duration(seconds: 2));
      expect(frontend.mockData.length, CHUNKS_SIZE * 2 + 1);
    }, skip: true);

    test('Check sending large amount of data via chunks from Backend to Frontend with sync style method', () async {
      final frontend = FrontendExample();
      await frontend.init();
      await frontend.getLargeDataSync();
      expect(frontend.mockData.length, CHUNKS_SIZE * 2 + 1);
    });
  });
}
