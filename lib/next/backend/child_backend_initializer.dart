import 'package:flutter/foundation.dart';
import 'package:isolator/next/backend/backend.dart';
import 'package:isolator/next/backend/backend_argument.dart';
import 'package:isolator/next/types.dart';

@immutable
class ChildBackendInitializer<T, B extends Backend> {
  const ChildBackendInitializer({
    required this.initializer,
    required this.argument,
    required this.backendId,
  });

  final BackendInitializer<T, B> initializer;
  final BackendArgument<T> argument;
  final BackendId backendId;
}
