import 'package:isolator/src/types.dart';

/// Abstract class for messages between Backends and DataBus
abstract class DataBusDto<Event> {
  Event get event;

  BackendId get to;

  BackendId get from;

  String get id;
}
