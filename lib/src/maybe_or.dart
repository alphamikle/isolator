import 'package:flutter/cupertino.dart';

@immutable
class MaybeOr<T> {
  const MaybeOr({
    required this.value,
    required this.error,
  });

  factory MaybeOr.ok(T value) {
    return MaybeOr(value: value, error: null);
  }

  factory MaybeOr.error(dynamic error) {
    return MaybeOr(value: null, error: error);
  }

  final T? value;
  final dynamic error;

  bool get hasError => error != null;
  bool get hasValue => error != null;
}
