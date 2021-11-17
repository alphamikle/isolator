import 'dart:isolate';

import 'package:isolator/next/in/in_abstract.dart';

class InNative implements In {
  late final SendPort _sendPort;

  @override
  void send<T>(T data) => _sendPort.send(data);

  void initSendPort(SendPort sendPort) => _sendPort = sendPort;
}

In createIn() => InNative();