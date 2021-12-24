import 'package:flutter/foundation.dart';
import 'package:isolator/src/in/in_abstract.dart';

@immutable
class DataBusInitResult {
  const DataBusInitResult({
    required this.backendToDataBusIn,
  });

  final In backendToDataBusIn;
}
