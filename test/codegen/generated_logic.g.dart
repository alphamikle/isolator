// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generated_logic.dart';

// **************************************************************************
// IsolatedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND.

class GeneratedLogicIsolate with Frontend implements IsolatedHandle {
  GeneratedLogicIsolate._();

  Future<void> _init({
    int? poolId,
    required int seed,
    String suffix = '!',
  }) async {
    await initBackend<_$GeneratedLogicInit, _$GeneratedLogicBackend>(
      initializer: _$createGeneratedLogicBackend,
      poolId: poolId,
      data: _$GeneratedLogicInit(seed, suffix: suffix),
    );
  }

  @override
  void initActions() {}

  @override
  Future<void> destroy() async {
    await super.destroy();
  }

  Future<int> add(int value) async {
    final Maybe<int> response =
        await run<_$GeneratedLogicEvent, _$GeneratedLogicAddRequest, int>(
      event: _$GeneratedLogicEvent.add,
      data: _$GeneratedLogicAddRequest(value),
    );
    if (response.hasError) {
      throw response.error;
    }
    return response.value;
  }

  Future<void> ensurePositive(int value) async {
    final Maybe<Object?> response = await run<_$GeneratedLogicEvent,
        _$GeneratedLogicEnsurePositiveRequest, Object?>(
      event: _$GeneratedLogicEvent.ensurePositive,
      data: _$GeneratedLogicEnsurePositiveRequest(value),
    );
    if (response.hasError) {
      throw response.error;
    }
  }

  Future<String> label(String value, {String separator = '-'}) async {
    final Maybe<String> response =
        await run<_$GeneratedLogicEvent, _$GeneratedLogicLabelRequest, String>(
      event: _$GeneratedLogicEvent.label,
      data: _$GeneratedLogicLabelRequest(value, separator: separator),
    );
    if (response.hasError) {
      throw response.error;
    }
    return response.value;
  }

  String localDebug() {
    throw UnsupportedError(
        'Method `localDebug` is marked with @isolatedIgnore and is unavailable on the generated isolate proxy.');
  }

  Future<int> sum(int first, [int second = 10]) async {
    final Maybe<int> response =
        await run<_$GeneratedLogicEvent, _$GeneratedLogicSumRequest, int>(
      event: _$GeneratedLogicEvent.sum,
      data: _$GeneratedLogicSumRequest(first, second),
    );
    if (response.hasError) {
      throw response.error;
    }
    return response.value;
  }
}

Future<GeneratedLogicIsolate> createGeneratedLogicIsolate(int _seed,
    {String suffix = '!', int? poolId}) async {
  final frontend = GeneratedLogicIsolate._();
  await frontend._init(
    poolId: poolId,
    seed: _seed,
    suffix: suffix,
  );
  return frontend;
}

enum _$GeneratedLogicEvent {
  add,
  ensurePositive,
  label,
  sum,
}

class _$GeneratedLogicInit {
  final int _seed;
  final String suffix;

  const _$GeneratedLogicInit(this._seed, {this.suffix = '!'});
}

class _$GeneratedLogicAddRequest {
  final int value;

  const _$GeneratedLogicAddRequest(this.value);
}

class _$GeneratedLogicEnsurePositiveRequest {
  final int value;

  const _$GeneratedLogicEnsurePositiveRequest(this.value);
}

class _$GeneratedLogicLabelRequest {
  final String value;
  final String separator;

  const _$GeneratedLogicLabelRequest(this.value, {this.separator = '-'});
}

class _$GeneratedLogicSumRequest {
  final int first;
  final int second;

  const _$GeneratedLogicSumRequest(this.first, [this.second = 10]);
}

class _$GeneratedLogicBackend extends Backend<_$GeneratedLogicInit> {
  _$GeneratedLogicBackend({
    required BackendArgument<_$GeneratedLogicInit> argument,
  })  : _target = _createTarget(argument.data),
        super(argument: argument);

  final GeneratedLogic _target;

  static GeneratedLogic _createTarget(_$GeneratedLogicInit? data) {
    if (data == null) {
      throw StateError(
          'Missing initialization data for GeneratedLogic isolate.');
    }
    return GeneratedLogic(data._seed, suffix: data.suffix);
  }

  @override
  void initActions() {
    whenEventCome(_$GeneratedLogicEvent.add).run(_add);
    whenEventCome(_$GeneratedLogicEvent.ensurePositive).run(_ensurePositive);
    whenEventCome(_$GeneratedLogicEvent.label).run(_label);
    whenEventCome(_$GeneratedLogicEvent.sum).run(_sum);
  }

  Future<int> _add(
      {required _$GeneratedLogicEvent event,
      required _$GeneratedLogicAddRequest data}) async {
    return await _target.add(data.value);
  }

  Future<Object?> _ensurePositive(
      {required _$GeneratedLogicEvent event,
      required _$GeneratedLogicEnsurePositiveRequest data}) async {
    await _target.ensurePositive(data.value);
    return null;
  }

  Future<String> _label(
      {required _$GeneratedLogicEvent event,
      required _$GeneratedLogicLabelRequest data}) async {
    return await _target.label(data.value, separator: data.separator);
  }

  Future<int> _sum(
      {required _$GeneratedLogicEvent event,
      required _$GeneratedLogicSumRequest data}) async {
    return await _target.sum(data.first, data.second);
  }
}

_$GeneratedLogicBackend _$createGeneratedLogicBackend(
  BackendArgument<_$GeneratedLogicInit> argument,
) {
  return _$GeneratedLogicBackend(argument: argument);
}
