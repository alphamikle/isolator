import 'package:flutter_test/flutter_test.dart';

import 'isolate_exit/consumer.dart';

Future<void> main() async {
  group('Isolate exit test', () {
    test('Run action with large data and [Isolate.exit]', () async {
      await getValuesFromIsolate();
    });
  });
}
