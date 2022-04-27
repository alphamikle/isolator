library isolator;

import 'package:isolator/src/backend/backend.dart';
import 'package:isolator/src/data_bus/data_bus.dart';
import 'package:isolator/src/types.dart';

/// Abstract class for messages between [Backend]'s and [DataBus]
abstract class DataBusDto<Event> {
  /// ID ot the message
  Event get event;

  /// ID of the [Backend]-consumer
  BackendId get to;

  /// ID of the [Backend]-sender
  BackendId get from;

  /// ID to identify the same message between [Backend]'s
  String get id;
}
