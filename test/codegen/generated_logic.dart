import 'package:isolator/isolator.dart';

part 'generated_logic.g.dart';

@isolated
class GeneratedLogic {
  GeneratedLogic(this._seed, {String suffix = '!'}) : _suffix = suffix;

  final int _seed;
  final String _suffix;

  Future<int> add(int value) async {
    return _seed + value;
  }

  Future<String> label(
    String value, {
    String separator = '-',
  }) async {
    return '$value$separator$_suffix';
  }

  Future<int> sum(int first, [int second = 10]) async {
    return _seed + first + second;
  }

  Future<void> ensurePositive(int value) async {
    if (value < 0) {
      throw StateError('negative: $value');
    }
  }

  @isolatedIgnore
  String localDebug() {
    return '$_seed$_suffix';
  }
}
