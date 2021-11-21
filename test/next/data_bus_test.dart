import 'package:flutter_test/flutter_test.dart';

import 'data_bus/first_front.dart';
import 'data_bus/second_front.dart';
import 'template/mock_data.dart';

FirstFront? firstFrontend;
FirstFront get firstFront => firstFrontend!;

SecondFront? secondFrontend;
SecondFront get secondFront => secondFrontend!;

Future<void> main() async {
  group('Data bus test', () {
    setUp(() async {
      firstFrontend = FirstFront();
      secondFrontend = SecondFront();

      await Future.wait([
        firstFront.init(),
        secondFront.init(),
      ]);
    });

    tearDown(() async {
      await firstFront.dispose();
      firstFrontend = null;

      await secondFront.dispose();
      secondFrontend = null;
    });

    test('Run action [computeInt]', () async {
      final int result = await firstFront.computeInt();
      expect(result, 42);
    });

    test('Run action [computeChunks]', () async {
      const int targetLength = 5000;
      final List<MockData> result = await firstFront.computeChunks(targetLength);
      expect(result.length, targetLength);
    });
  });
}
