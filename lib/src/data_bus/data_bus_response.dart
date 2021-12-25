import 'package:isolator/src/data_bus/data_bus_dto.dart';
import 'package:isolator/src/maybe.dart';
import 'package:isolator/src/types.dart';
import 'package:meta/meta.dart';

/// Wrapper for messages between Backend and DataBus
/// (request from one Backend to another through DataBus)
@immutable
class DataBusResponse<Event, Data> implements DataBusDto<Event> {
  const DataBusResponse({
    required this.event,
    required this.data,
    required this.to,
    required this.from,
    required this.id,
  });

  @override
  final Event event;

  final Maybe<Data> data;

  @override
  final BackendId to;

  @override
  final BackendId from;

  @override
  final String id;
}
