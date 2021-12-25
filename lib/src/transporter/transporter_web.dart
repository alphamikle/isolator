import 'package:isolator/src/transporter/container.dart';

/// Inner layer helper for the Transporter
Future<void> sendThroughTransporter<Event, Data>(
  Container<Event, Data> container, {
  bool sendDirectly = false,
}) async {
  container.toFrontendIn.send(container.message);
}
