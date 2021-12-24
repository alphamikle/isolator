import 'package:isolator/src/transporter/container.dart';

Future<void> sendThroughTransporter<Event, Data>(Container<Event, Data> container, {bool sendDirectly = false}) async {
  container.toFrontendIn.send(container.message);
}
