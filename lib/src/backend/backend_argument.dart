library isolator;

import 'package:flutter/foundation.dart';
import 'package:isolator/src/in/in_abstract.dart';

@immutable
class BackendArgument<T> {
  const BackendArgument({
    required this.toFrontendIn,
    required this.toDataBusIn,
    this.data,
  });

  final In toFrontendIn;
  final In toDataBusIn;
  final T? data;
}
