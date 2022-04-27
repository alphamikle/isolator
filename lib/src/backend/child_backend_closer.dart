library isolator;

import 'package:isolator/src/backend/backend.dart';
import 'package:isolator/src/types.dart';
import 'package:meta/meta.dart';

/// Special argument, which using to close [Backend]
@immutable
class ChildBackendCloser {
  /// Constructor
  const ChildBackendCloser({
    required this.backendId,
  });

  /// ID of the [Backend], which will be closed
  final BackendId backendId;
}
