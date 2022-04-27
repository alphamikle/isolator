library isolator;

import 'dart:isolate';

import 'package:isolator/src/in/in_abstract.dart';

/// [In] with [SendPort] to native platforms
class InNative implements In {
  late final SendPort _sendPort;

  @override
  void send<T>(T data) => _sendPort.send(data);

  /// Inner package method
  void initSendPort(SendPort sendPort) => _sendPort = sendPort;

  /// Inner package getter
  SendPort get sendPort => _sendPort;
}

/// Inner package factory
In createIn() => InNative();
