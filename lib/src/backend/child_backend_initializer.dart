library isolator;

import 'package:isolator/src/backend/backend.dart';
import 'package:isolator/src/backend/backend_argument.dart';
import 'package:isolator/src/types.dart';
import 'package:meta/meta.dart';

/// Special class to initialize [Backend] in the existing pool
@immutable
class ChildBackendInitializer<T, B extends Backend> {
  /// Constructor
  const ChildBackendInitializer({
    required this.initializer,
    required this.argument,
    required this.backendId,
  });

  /// Entry point to opening the [Backend]
  final BackendInitializer<T, B> initializer;

  /// Data, that will be passed to the opening [Backend]
  final BackendArgument<T> argument;

  /// ID of the opening [Backend]
  final BackendId backendId;
}
