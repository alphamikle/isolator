part of 'isolator.dart';

class _Utils {
  static bool isFunctionWithParam(Function function) {
    final RegExp regExp = RegExp(r'\(.+\)');
    return regExp.hasMatch(function.runtimeType.toString());
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
