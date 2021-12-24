import 'package:isolator/src/tools/helpers.dart';
import 'package:isolator/src/types.dart';

class Maybe<T> {
  Maybe({
    required dynamic data,
    required dynamic error,
  }) : _error = error {
    if (data is List) {
      _value = null;
      _list = data.cast<T>();
    } else if (data != null) {
      _value = data as T;
      _list = null;
    } else {
      _value = null;
      _list = null;
    }
  }

  late final T? _value;
  late final List<T>? _list;
  final Object? _error;

  T get value {
    if (_value == null || _value is! T) {
      if (_error != null) {
        throw Exception(error.toString());
      }
      throw Exception('Maybe<$T> not contains value of type $T. Before use [value] getter - check if value exist through [hasValue] getter');
    }
    return _value as T;
  }

  List<T> get list {
    if (_list == null || _list is! List<T>) {
      if (_error != null) {
        throw Exception(error.toString());
      }
      throw Exception('Maybe<$T> not contains list of type $T. Before use [list] getter - check if list exist through [hasList] getter');
    }
    return _list!;
  }

  Object get error => _error!;

  bool get hasError => _error != null;

  bool get hasValue => _value != null;

  bool get hasList => _list != null;

  Maybe<E> castTo<E>() {
    if (hasValue) {
      return Maybe<E>(data: _value, error: null);
    } else if (hasList) {
      return Maybe<E>(data: _list, error: null);
    } else {
      return Maybe<E>(data: null, error: _error);
    }
  }

  Json toJson() => <String, dynamic>{
        'value': tryPrintAsJson(_value),
        'list': tryPrintAsJson(_list),
        'error': tryPrintAsJson(_error),
      };

  @override
  String toString() => prettyJson(toJson());
}
