import 'package:flutter/cupertino.dart';

@immutable
class MaybeOr<T> {
  const MaybeOr({
    required this.value,
    required this.error,
  });

  factory MaybeOr.ok(T value) {
    return MaybeOr<T>(value: value, error: null);
  }

  factory MaybeOr.error(dynamic error) {
    return MaybeOr<T>(value: null, error: error);
  }

  final T? value;
  final Object? error;

  bool get hasError => error != null;
  bool get hasValue => error != null;
}
