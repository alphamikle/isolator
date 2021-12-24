import 'package:flutter/foundation.dart';
import 'package:isolator/src/types.dart';

@immutable
class ChildBackendCloser {
  const ChildBackendCloser({
    required this.backendId,
  });

  final BackendId backendId;
}
