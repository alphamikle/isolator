class Utils {
  static bool isFunctionWithParam(Function function) {
    final RegExp regExp = RegExp(r'\(.+\)');
    return regExp.hasMatch(function.runtimeType.toString());
  }

  static bool isFunctionWithNamedParam(Function function) {
    final RegExp regExp = RegExp(r'\(.*\{.*\)');
    return regExp.hasMatch(function.runtimeType.toString());
  }

  static bool isFunctionWithSeveralSimpleParams(Function function) {
    final RegExp regExp = RegExp(r'\(\[?\w+\??\,+ \w+\??\]?\)');
    return regExp.hasMatch(function.runtimeType.toString());
  }

  static bool isFunctionWithSeveralGenerics(Function function) {
    int howMuchArrows = 0;
    bool isGeneric = false;
    bool isFistGenericArgumentEnded = false;
    final List<String> symbols = function.runtimeType.toString().split('');
    for (final String symbol in symbols) {
      if (symbol == '<') {
        howMuchArrows++;
        isGeneric = true;
      }
      if (symbol == '>') {
        howMuchArrows--;
      }
      if (isGeneric && howMuchArrows == 0) {
        isFistGenericArgumentEnded = true;
      }
      if (isFistGenericArgumentEnded && symbol == ',') {
        return true;
      }
    }
    return false;
  }

  static void validateFunctionAsATaskOrOperation(Function function) {
    if (isFunctionWithParam(function) && (isFunctionWithNamedParam(function) || isFunctionWithSeveralSimpleParams(function) || isFunctionWithSeveralGenerics(function))) {
      print('${function.toString()} function is invalid');
      throw Exception('''
      tasks and operations must follow these interfaces:
      <T>() => FutureOr<T>
      <T, V>(V argument) => FutureOr<T>
      <T, V>([V argument]) => FutureOr<T>
      ''');
    }
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
    return code.replaceAll(RegExp(' :.*'), '');
  }

  static List<T> extractItemsFromList<T>(List<T> items, int howMuch) {
    final List<T> response = <T>[];
    while (items.isNotEmpty && response.length < howMuch) {
      response.add(items.removeAt(0));
    }
    return response;
  }
}
