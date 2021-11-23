import 'package:flutter/foundation.dart';
import 'package:isolator/next/types.dart';

@immutable
class ChildBackendCloser {
  const ChildBackendCloser({
    required this.backendId,
  });

  final BackendId backendId;
}
