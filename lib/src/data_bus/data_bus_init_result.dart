library isolator;

import 'package:isolator/src/backend/backend.dart';
import 'package:isolator/src/in/in_abstract.dart';
import 'package:meta/meta.dart';

/// Class
@immutable
class DataBusInitResult {
  /// It is a response after creating DataBus
  const DataBusInitResult({
    required this.backendToDataBusIn,
  });

  /// [In], which will consume events from the all [Backend]'s
  final In backendToDataBusIn;
}
