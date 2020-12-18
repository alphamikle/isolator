part of 'isolator.dart';

class _Utils {
  static bool isFunctionWithParam(String functionToString) {
    final RegExp regExp = RegExp(r'\(.+\)');
    return regExp.hasMatch(functionToString);
  }

  static bool isCodeAndIdValid<T>(T id, String code) {
    return code.startsWith('$id : ');
  }

  static String generateCode<T>(T id) {
    final List<String> letters = 'abcdefghijklmnopqrstuvwxyz'.split('');
    letters.shuffle();
    final String code = letters.take(10).join();
    return '$id : $code';
  }

  static String getIdFromCode(String code) {
    return code.replaceAll(RegExp(r' :.*'), '');
  }
}
