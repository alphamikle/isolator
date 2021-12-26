library isolator;

import 'package:isolator/src/frontend/frontend.dart';
import 'package:isolator/src/tools/helpers.dart';
import 'package:isolator/src/types.dart';
import 'package:meta/meta.dart';

/// Inner package params
enum ServiceData {
  /// none
  none,

  /// init
  init,
}

/// Class
@immutable
class Message<Event, Data> {
  /// Message - is a wrapper for data, which sending between Frontend
  /// and Backend
  const Message({
    required this.event,
    required this.data,
    required this.code,
    required this.timestamp,
    required this.serviceData,
    this.forceUpdate = false,
  });

  /// Simple constructor without additional arguments
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

  /// ID of this message
  final Event event;

  /// Sent data
  final Data data;

  /// Unique code of each message
  final String code;

  /// Timestamp for inner package's goals
  final DateTime timestamp;

  /// Inner package param
  final ServiceData serviceData;

  /// If this param will be "true" - then [Frontend.onForceUpdate] method
  /// will be called
  final bool forceUpdate;

  /// JSON-converter
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
