import 'package:flutter_test/flutter_test.dart';
import 'package:isolator/next/utils.dart';

import 'back_send_to_front/front.dart';

Front? frontend;
Front get front => frontend!;

Future<void> main() async {
  group('Back send to front', () {
    setUp(() async {
      frontend = Front();
      await front.init();
    });

    tearDown(() async {
      await front.dispose();
      frontend = null;
    });

    test('Run action [getMessageWithValue]', () async {
      front.initValueMessageSending();
      await wait(50);
      expect(front.value, 42);
    });

    test('Run action [getMessageWithList]', () async {
      front.initListMessageSending();
      await wait(50);
      expect(front.values.length, 5);
      expect(front.uiWasUpdated, true);
    });

    test('Run action [getMessageWithChunks]', () async {
      front.initChunksMessageSending();
      await wait(1000);
      expect(front.chunks.length, 100);
    });

    test('Run action [getSeveralMessages]', () async {
      front.initSeveralMessagesSending();
      await wait(1200);
      expect(front.value, 42);
      expect(front.values.length, 5);
      expect(front.chunks.length, 100);
      expect(front.uiWasUpdated, true);
    });
  });
}
