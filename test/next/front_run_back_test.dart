import 'package:flutter_test/flutter_test.dart';
import 'package:isolator/next/maybe.dart';

import 'front_run_back/front.dart';
import 'template/mock_data.dart';

Front? frontend;
Front get front => frontend!;

Future<void> main() async {
  group('Front run back', () {
    setUp(() async {
      frontend = Front();
      await front.init();
    });

    tearDown(() async {
      await front.destroy();
      frontend = null;
    });

    test('Run action [doNothing]', () async {
      await front.doNothing();
      expect(true, true);
    });

    test('Run action [computeInt]', () async {
      final int result = await front.computeInt();
      expect(result, 42);
    });

    test('Run action [throwError]', () async {
      final Maybe<int> result = await front.throwError();
      expect(result.hasError, true);
    });

    test('Run action [computeChunks]', () async {
      final List<int> result = await front.computeChunks();
      expect(result.length, 5000);
    });

    test('Run action [computeList]', () async {
      final List<MockData> result = await front.computeList();
      expect(result.length, 100);
    });
  });
}
