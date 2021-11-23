import 'package:flutter_test/flutter_test.dart';

import 'backends_in_same_pool/first_front.dart';
import 'backends_in_same_pool/second_front.dart';

FirstFront? firstFrontend;
FirstFront get firstFront => firstFrontend!;

SecondFront? secondFrontend;
SecondFront get secondFront => secondFrontend!;

Future<void> main() async {
  group('Backends in same pool', () {
    setUp(() async {
      firstFrontend = FirstFront();
      secondFrontend = SecondFront();

      await Future.wait([
        firstFront.init(),
        secondFront.init(),
      ]);
    });

    tearDown(() async {
      await secondFront.dispose();
      secondFrontend = null;

      await firstFront.dispose();
      firstFrontend = null;
    });

    test('Run action [computeInt]', () async {
      final int firstResult = await firstFront.computeInt();
      final int secondResult = await secondFront.computeInt();
      expect(firstResult, 42);
      expect(secondResult, 42);
    });

    test('Run action [computeIntFromSecondBackend]', () async {
      final int result = await firstFront.computeIntFromSecondBackend();
      expect(result, 42);
    });
  });
}
