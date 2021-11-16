import 'package:flutter/foundation.dart';
import 'package:isolator/next/types.dart';
import 'package:isolator/next/utils.dart';

@immutable
class Maybe {
  const Maybe({
    required Object? data,
    required this.error,
  }) : _data = data;

  final Object? _data;
  final Object? error;

  T getData<T>() => _data as T;

  Json toJson() => <String, dynamic>{
        'data': tryPrintAsJson(_data),
        'error': tryPrintAsJson(error),
      };

  @override
  String toString() => prettyJson(toJson());
}
