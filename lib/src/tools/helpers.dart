import 'dart:convert';

import 'package:isolator/src/types.dart';

const _eventCodeSplitter = '::::::::::::::';

/// Format JSON to pretty human-readable view
String prettyJson(Json json) {
  const jsonEncoder = JsonEncoder.withIndent(' ');
  return jsonEncoder.convert(json);
}

/// Wrapper to safe running any function
T? tryToCall<T>(dynamic object, Caller<T> caller) {
  try {
    return caller(object);
  } catch (error) {
    return null;
  }
}

/// Wrapper to safe format any data to JSON
Object tryPrintAsJson(dynamic object) {
  final json = tryToCall<Json>(
    object,
    (dynamic object) => object.toJson() as Json,
  );
  if (json != null) {
    return json;
  }
  return Error.safeToString(object);
}

/// Message code generator for package
String generateMessageCode(dynamic event, {bool syncChunkEvent = false}) {
  final code = generateSimpleRandomCode();
  return '$event$_eventCodeSplitter$code';
}

/// Simple random code generator
String generateSimpleRandomCode() {
  final letters = '0123456789abcdefghijklmnopqrstuvwxyz'.split('')..shuffle();
  return letters.take(12).join();
}

/// Convert error to string
String errorToString(dynamic error) => error.toString();

/// Convert stackTrace to string
String errorStackTraceToString(dynamic error) {
  try {
    return error.stackTrace?.toString() ?? 'NO STACK TRACE';
  } catch (error) {
    // Handle error
    return 'NOT AN ERROR WITH STACK TRACE: $error';
  }
}

/// Using to print pretty messages between Backend's errors
String getNameOfParentRunningFunction(String stacktraceString) {
  final regExp = RegExp('#1 +(.*) ');
  final matches = regExp.firstMatch(stacktraceString);
  if (matches != null) {
    return matches.group(1)!;
  }
  return 'UNKNOWN';
}

/// Convert object to typed string
String objectToTypedString(dynamic object) {
  return '<${object.runtimeType}>$object';
}

/// Simple async debounce
Future<void> wait(int milliseconds) async => Future.delayed(
      Duration(milliseconds: milliseconds),
    );
