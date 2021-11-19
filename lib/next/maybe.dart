import 'package:isolator/next/types.dart';
import 'package:isolator/next/utils.dart';

class Maybe<T> {
  Maybe({
    required dynamic data,
    required dynamic error,
  }) : _error = error {
    if (data is List) {
      _value = null;
      _list = data as List<T>;
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

  T get value => _value!;

  List<T> get list => _list!;

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
