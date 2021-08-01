part of 'isolator.dart';

@immutable
class Optional<T> {
  const Optional(this.value);

  final T? value;
}
