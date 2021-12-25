library isolator;

import 'package:meta/meta.dart';
import 'package:isolator/src/in/in_abstract.dart';

/// Wrapper for data, which will send to Backend, when
/// Frontend will initialize that
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
