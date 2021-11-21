import 'package:flutter/foundation.dart';
import 'package:isolator/next/data_bus/data_bus_dto.dart';
import 'package:isolator/next/types.dart';

@immutable
class DataBusRequest<Event, Data> implements DataBusDto<Event> {
  const DataBusRequest({
    required this.event,
    required this.data,
    required this.to,
    required this.from,
    required this.id,
  });

  @override
  final Event event;

  final Data? data;

  @override
  final BackendId to;

  @override
  final BackendId from;

  @override
  final String id;
}
