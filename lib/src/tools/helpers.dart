import 'dart:convert';

import 'package:isolator/src/types.dart';

const String eventCodeSplitter = '::::::::::::::';

String prettyJson(Json json) {
  const JsonEncoder jsonEncoder = JsonEncoder.withIndent(' ');
  return jsonEncoder.convert(json);
}

T? tryToCall<T>(dynamic object, Caller<T> caller) {
  try {
    return caller(object);
  } catch (error) {
    return null;
  }
}

Object tryPrintAsJson(dynamic object) {
  final Json? json = tryToCall<Json>(object, (dynamic object) => object.toJson() as Json);
  if (json != null) {
    return json;
  }
  return Error.safeToString(object);
}

String generateMessageCode(dynamic event, {bool syncChunkEvent = false}) {
  final String code = generateSimpleRandomCode();
  return '$event$eventCodeSplitter$code';
}

String generateSimpleRandomCode() {
  final List<String> letters = '0123456789abcdefghijklmnopqrstuvwxyz'.split('');
  letters.shuffle();
  return letters.take(12).join();
}

String errorToString(dynamic error) => error.toString();

String errorStackTraceToString(dynamic error) {
  try {
    return error.stackTrace?.toString() ?? 'NO STACK TRACE';
  } catch (error) {
    // Handle error
    return 'NOT AN ERROR WITH STACK TRACE: $error';
  }
}

String getNameOfParentRunningFunction(String stacktraceString) {
  final RegExp regExp = RegExp('#1 +(.*) ');
  final RegExpMatch? matches = regExp.firstMatch(stacktraceString);
  if (matches != null) {
    return matches.group(1)!;
  }
  return 'UNKNOWN';
}

String objectToTypedString(dynamic object) {
  return '<${object.runtimeType}>$object';
}

Future<void> wait(int milliseconds) async => Future.delayed(Duration(milliseconds: milliseconds));
