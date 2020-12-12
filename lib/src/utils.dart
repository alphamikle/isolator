import 'dart:math';

import 'package:path_provider/path_provider.dart';

class Utils {
  static Future<void> wait(int ms, {Function callback}) async {
    await Future<void>.delayed(Duration(milliseconds: ms ?? 100), () {
      if (callback != null) {
        callback();
      }
    });
  }

  static String _documentPath;

  static Future<String> getDocumentsPath() async {
    _documentPath ??= (await getApplicationDocumentsDirectory()).path;
    return _documentPath;
  }

  static bool isFunctionWithParam(String functionToString) {
    final RegExp regExp = RegExp(r'\(.+\)');
    return regExp.hasMatch(functionToString);
  }

  static String getFunctionName(dynamic function) {
    final String match = RegExp(r"'[a-zA-Z]+'").firstMatch('$function').group(0);
    return match.replaceAll('\'', '');
  }

  static double getRandomBetween(double min, double max) {
    final Random random = Random(Random(Random().nextInt(1000)).nextInt(1000));
    return random.nextDouble() * (max - min) + min;
  }

  static bool getRandomBool() => Random().nextBool();

  static int _boolIncrement = getRandomBool() ? 0 : 1;
  static bool getNextBool() {
    final bool nextBool = _boolIncrement.isEven ? true : false;
    _boolIncrement++;
    return nextBool;
  }
}
