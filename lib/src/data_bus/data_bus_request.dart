library isolator;

import 'package:isolator/src/backend/backend.dart';
import 'package:isolator/src/data_bus/data_bus.dart';
import 'package:isolator/src/data_bus/data_bus_dto.dart';
import 'package:isolator/src/types.dart';
import 'package:meta/meta.dart';

/// Class
@immutable
class DataBusRequest<Event, Data> implements DataBusDto<Event> {
  /// Wrapper for messages between [Backend] and [DataBus]
  /// (request from one [Backend] to another through [DataBus])
  const DataBusRequest({
    required this.event,
    required this.data,
    required this.to,
    required this.from,
    required this.id,
  });

  @override
  final Event event;

  /// Some data, which will be sent from one [Backend] to another
  final Data? data;

  @override
  final BackendId to;

  @override
  final BackendId from;

  @override
  final String id;
}
