import 'package:flutter/foundation.dart';
import 'package:isolator/next/in/in_abstract.dart';

enum MessageType {
  add,
  remove,
}

@immutable
class DataBusBackendInitMessage {
  const DataBusBackendInitMessage({
    required this.backendIn,
    required this.backendId,
    required this.type,
  });

  final In backendIn;
  final String backendId;
  final MessageType type;
}
