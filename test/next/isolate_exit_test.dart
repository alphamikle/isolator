import 'package:flutter_test/flutter_test.dart';

import 'isolate_exit/consumer.dart';
import 'template/mock_data.dart';

Future<void> main() async {
  group('Isolate exit test', () {
    test('Run action with large data and [Isolate.exit]', () async {
      final List<MockData> result = await getValuesFromIsolate();
      expect(result.runtimeType, List<MockData>);
    });
  });
}
