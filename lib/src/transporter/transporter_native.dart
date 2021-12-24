import 'dart:isolate';

import 'package:isolator/src/in/in_native.dart';
import 'package:isolator/src/transporter/container.dart';

Future<void> sendThroughTransporter<Event, Data>(Container<Event, Data> container,
    {bool sendDirectly = false}) async {
  if (sendDirectly) {
    container.toFrontendIn.send(container.message);
  } else {
    await Isolate.spawn(_sender, container);
  }
}

void _sender<Event, Data>(Container<Event, Data> container) {
  Isolate.exit((container.toFrontendIn as InNative).sendPort, container.message);
}
