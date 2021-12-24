import 'package:isolator/src/transporter/container.dart';

Future<void> sendThroughTransporter<Event, Data>(Container<Event, Data> container,
        {bool sendDirectly = false}) =>
    throw UnimplementedError('Use native or web implementation of transporter function');
