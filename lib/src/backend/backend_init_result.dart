library isolator;

import 'package:flutter/foundation.dart';
import 'package:isolator/src/in/in_abstract.dart';

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
