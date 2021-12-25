import 'package:isolator/src/tools/helpers.dart';
import 'package:isolator/src/types.dart';
import 'package:meta/meta.dart';

/// Maybe<T> - is a wrapper for Backend's calls responses. If you will use
/// [Frontend.run] method - you will always getting a some response
///
/// If Backend return some value - this value will be in Maybe<T>
/// If Backend will thrown with Exception - this exception will be in Maybe<T>
@immutable
class Maybe<T> {
  const Maybe({
    required T? data,
    required Object? error,
  })  : _error = error,
        _value = data;

  final T? _value;
  final Object? _error;

  T get value {
    if (_value == null || _value is! T) {
      if (_error != null) {
        throw Exception(error.toString());
      }
      throw Exception(
          'Maybe<$T> not contains value of type $T. Before use [value] getter - check if value exist through [hasValue] getter');
    }
    return _value as T;
  }

  Maybe<E> castTo<E>() {
    if (hasValue) {
      return Maybe<E>(data: _value as E, error: null);
    } else {
      return Maybe<E>(data: null, error: _error);
    }
  }

  Object get error => _error!;

  bool get hasError => _error != null;

  bool get hasValue => _value != null;

  Json toJson() => <String, dynamic>{
        'value': tryPrintAsJson(_value),
        'error': tryPrintAsJson(_error),
      };

  @override
  String toString() => prettyJson(toJson());
}
