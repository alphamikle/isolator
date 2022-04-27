library isolator;

import 'package:isolator/src/backend/backend.dart';
import 'package:isolator/src/data_bus/data_bus.dart';
import 'package:isolator/src/frontend/frontend.dart';
import 'package:isolator/src/in/in_abstract.dart';
import 'package:isolator/src/isolator/isolator_abstract.dart';
import 'package:meta/meta.dart';

/// This is a response from the [Backend], which created after [Isolator]
/// creates this one
@immutable
class BackendInitResult {
  /// Constructor
  const BackendInitResult({
    required this.frontendToBackendIn,
    required this.dataBusToBackendIn,
    required this.timestamp,
  });

  /// [In], which will consume messages from [Frontend] to
  /// corresponding [Backend]
  final In frontendToBackendIn;

  /// [In], which will consume messages from [DataBus] to
  /// corresponding [Backend]
  final In dataBusToBackendIn;

  /// For package needs
  final DateTime timestamp;
}
