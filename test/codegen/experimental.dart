import 'package:isolator/isolator.dart';

class ExperimentalClass with Frontend, _$ExperimentalClassIsolator {
  @override
  Future<int> sum(int a, int b) async {
    return a + b;
  }
}

mixin _$ExperimentalClassIsolator on Frontend {
  @override
  void initActions() {}

  Future<int> sum(int a, int b) async {
    final Maybe<int> result = await run(event: 'sum', data: [a, b]);

    if (result.hasError) {
      throw result.error;
    }

    return result.value;
  }
}

class _$ExperimentalClassFiller {
  Future<int> sum(int a, int b) async {
    return a + b;
  }
}

class _$ExperimentalClassBackend extends Backend {
  _$ExperimentalClassBackend({
    required super.argument,
  }) {
    filler = _$ExperimentalClassFiller();
  }

  late final _$ExperimentalClassFiller filler;

  @override
  void initActions() {
    whenEventCome('sum')
        .runSimple((List<int> data) => filler.sum(data[0], data[1]));
  }
}
