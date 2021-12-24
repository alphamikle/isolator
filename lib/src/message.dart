library isolator;

import 'package:flutter/foundation.dart';
import 'package:isolator/src/tools/helpers.dart';
import 'package:isolator/src/types.dart';

enum ServiceData {
  none,
  init,
  transactionStart,
  transactionContinue,
  transactionEnd,
  transactionAbort,
}

@immutable
class Message<Event, Data> {
  const Message({
    required this.event,
    required this.data,
    required this.code,
    required this.timestamp,
    required this.serviceData,
    this.forceUpdate = false,
  });

  factory Message.simple({
    required Event event,
    required Data data,
  }) {
    return Message(
      event: event,
      data: data,
      code: '',
      timestamp: DateTime.now(),
      serviceData: ServiceData.none,
      forceUpdate: false,
    );
  }

  final Event event;
  final Data data;
  final String code;
  final DateTime timestamp;
  final ServiceData serviceData;
  final bool forceUpdate;

  bool get isChunksMessage {
    return serviceData == ServiceData.transactionAbort || serviceData == ServiceData.transactionStart || serviceData == ServiceData.transactionEnd || serviceData == ServiceData.transactionContinue;
  }

  Json toJson() => <String, dynamic>{
        'event': tryPrintAsJson(event),
        'data': tryPrintAsJson(data),
        'code': code,
        'timestamp': timestamp.toIso8601String(),
        'serviceData': serviceData.toString(),
        'forceUpdate': forceUpdate,
      };

  @override
  String toString() => prettyJson(toJson());
}
