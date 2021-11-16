import 'dart:convert';

import 'package:isolator/next/types.dart';

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
