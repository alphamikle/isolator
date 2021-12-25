library isolator;

import 'package:isolator/src/in/in_abstract.dart';
import 'package:meta/meta.dart';

/// This is a response from the Backend, which used in inner layer of package
@immutable
class BackendInitResult {
  const BackendInitResult({
    required this.frontendToBackendIn,
    required this.dataBusToBackendIn,
    required this.timestamp,
  });

  final In frontendToBackendIn;
  final In dataBusToBackendIn;
  final DateTime timestamp;
}
