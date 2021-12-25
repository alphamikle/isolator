library isolator;

import 'package:isolator/src/backend/backend.dart';
import 'package:isolator/src/data_bus/data_bus.dart';
import 'package:isolator/src/in/in_abstract.dart';
import 'package:isolator/src/types.dart';
import 'package:meta/meta.dart';

/// ID's for create or destroy [Backend]'s in the [DataBus]
enum MessageType {
  /// Adding [Backend] in [DataBus} ID
  add,

  /// Removing [Backend] from [DataBus} ID
  remove,
}

/// [DataBusBackendInitMessage] class
@immutable
class DataBusBackendInitMessage {
  /// Helper to register and unregister Backends in DataBus
  const DataBusBackendInitMessage({
    required this.backendIn,
    required this.backendId,
    required this.type,
  });

  /// [In], which will consume events from [DataBus] to corresponding [Backend]
  final In? backendIn;

  /// ID of the [Backend]
  final BackendId backendId;

  /// Type of the [DataBusBackendInitMessage]
  final MessageType type;
}
