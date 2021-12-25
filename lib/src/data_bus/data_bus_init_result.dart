import 'package:isolator/src/in/in_abstract.dart';
import 'package:meta/meta.dart';

/// It is a response after creating DataBus
@immutable
class DataBusInitResult {
  const DataBusInitResult({
    required this.backendToDataBusIn,
  });

  final In backendToDataBusIn;
}
