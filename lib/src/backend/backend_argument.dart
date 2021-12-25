library isolator;

import 'package:isolator/src/backend/backend.dart';
import 'package:isolator/src/data_bus/data_bus.dart';
import 'package:isolator/src/frontend/frontend.dart';
import 'package:isolator/src/in/in_abstract.dart';
import 'package:isolator/src/tools/packet.dart';
import 'package:meta/meta.dart';

/// Wrapper for data, which will send to Backend, when
/// Frontend will initialize that
@immutable
class BackendArgument<T> {
  /// Constructor
  const BackendArgument({
    required this.toFrontendIn,
    required this.toDataBusIn,
    this.data,
  });

  /// [In], which will consume messages from [Backend] to
  /// corresponding [Frontend]
  final In toFrontendIn;

  /// [In], which will consume messages from [Backend] to the [DataBus]
  final In toDataBusIn;

  /// This is a some data, which you can pass into the [Backend],
  /// when create it from the UI thread
  ///
  /// For passing many arguments from the UI thread you can use the [Packet]
  final T? data;
}
