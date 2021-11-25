import 'dart:math';

void main() {
  const String start = 'Mikhail Alfa';
  const String end = 'Алёна Кондрух';

  final List<int> startBytes = toBytes(start);
  final List<int> endBytes = toBytes(end);

  const int steps = 250;
  print('${startBytes.join()} -> ${endBytes.join()}');
  for (int s = 0; s < steps; s++) {
    final List<int> result = [];
    final bool isLastStep = s == steps - 1;
    final int currentMaxLength = (start.length - ((start.length - end.length) * s / steps)).round();
    for (int i = 0; i < max(startBytes.length, endBytes.length); i++) {
      final int startByte = startBytes.length > i ? startBytes[i] : 0;
      final int endByte = endBytes.length > i ? endBytes[i] : 0;

      /// 85 - start, 30 - end, 100 frames
      /// 1-th frame: 85 - ((85 - 30) * 1 / 100) = 84.45
      /// 50-th frame: 85 - ((85 - 30) * 50 / 100) = 57.5
      /// 100-th frame: 85 - ((85 - 30) * 100 / 100) = 30
      final int resultByte = isLastStep ? endByte : (startByte - ((startByte - endByte) * s / steps)).round();
      result.add(resultByte);
    }
    final String resultString = Uri.encodeComponent(toString(result));
    print('[$s / $steps ::: $currentMaxLength / ${end.length} / ${resultString.length}] $resultString');
  }
}

List<int> toBytes(String string) {
  // return string.codeUnits;
  return string.runes.toList();
  // return utf8.encoder.convert(string);
}

String toString(List<int> bytes) {
  final String result = String.fromCharCodes(bytes);
  if (false) {
    return result.replaceAll(RegExp(r'[^a-z0-9а-я-_ )(\.,|:ё]', caseSensitive: false, multiLine: true, unicode: true), ' ');
  }
  return result;
}
