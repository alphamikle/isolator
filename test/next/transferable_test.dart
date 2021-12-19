import 'package:flutter_test/flutter_test.dart';

import 'transferable/front.dart';

Front? frontend;
Front get front => frontend!;

// TODO(alphamikle): In research of needing
Future<void> main() async {
  group('Transferable', () {
    setUp(() async {
      frontend = Front();
      await front.init();
    });

    tearDown(() async {
      await front.destroy();
      frontend = null;
    });

    test('Run action [getBigData]', () async {
      final String result = await front.getBigData();
      expect('', '');
    }, skip: true);

    test('Run action [getBigDataAsList]', () async {
      final String result = await front.getBigDataAsList();
      expect('', '');
    }, skip: true);
  });
}
