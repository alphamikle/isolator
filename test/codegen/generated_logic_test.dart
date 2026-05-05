import 'package:flutter_test/flutter_test.dart';

import 'generated_logic.dart';

void main() {
  test('generated isolate proxy runs logic in backend isolate', () async {
    final GeneratedLogicIsolate logic = await createGeneratedLogicIsolate(
      5,
      suffix: '?',
    );

    expect(await logic.add(7), 12);
    expect(await logic.sum(3), 18);
    expect(await logic.sum(3, 4), 12);
    expect(await logic.label('hello'), 'hello-?');
    expect(
      await logic.label(
        'hello',
        separator: '/',
      ),
      'hello/?',
    );

    await logic.destroy();
  });

  test(
      'generated proxy propagates backend errors and ignored methods fail fast',
      () async {
    final GeneratedLogicIsolate logic = await createGeneratedLogicIsolate(2);

    expect(logic.localDebug, throwsA(isA<UnsupportedError>()));
    await expectLater(
      logic.ensurePositive(-1),
      throwsA(isA<StateError>()),
    );

    await logic.destroy();
  });
}
