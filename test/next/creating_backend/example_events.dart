import 'package:flutter/foundation.dart';

abstract class ExampleEvent {}

@immutable
class ExampleEventMarkI {}

@immutable
class ExampleEventMarkII {
  const ExampleEventMarkII({
    required this.value,
  });

  final int value;
}
