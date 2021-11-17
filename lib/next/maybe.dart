import 'package:flutter/foundation.dart';
import 'package:isolator/next/types.dart';
import 'package:isolator/next/utils.dart';
import 'package:isolator/src/benchmark.dart';

@immutable
class Maybe {
  const Maybe({
    required Object? data,
    required this.error,
  }) : _data = data;

  final Object? _data;
  final Object? error;

  T getData<T>() => _data as T;
  List<T> getListData<T>() {
    bench.start('Cast list to <$T>');
    final response = (_data! as List).cast<T>();
    bench.end('Cast list to <$T>');
    return response;
  }

  Json toJson() => <String, dynamic>{
        'data': tryPrintAsJson(_data),
        'error': tryPrintAsJson(error),
      };

  @override
  String toString() => prettyJson(toJson());
}
