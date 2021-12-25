import 'package:isolator/src/types.dart';
import 'package:meta/meta.dart';

/// Special argument, which using to close Backend
@immutable
class ChildBackendCloser {
  const ChildBackendCloser({
    required this.backendId,
  });

  final BackendId backendId;
}
