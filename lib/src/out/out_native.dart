library isolator;

import 'dart:async';
import 'dart:isolate';

import 'package:isolator/src/in/in_abstract.dart';
import 'package:isolator/src/in/in_native.dart';
import 'package:isolator/src/out/out_abstract.dart';
import 'package:isolator/src/types.dart';

/// Out implementation for a native platforms
class OutNative<T> implements Out<T> {
  late final ReceivePort _receivePort = ReceivePort();
  late final Stream<dynamic> _stream = _receivePort.asBroadcastStream();

  @override
  In get createIn => InNative()..initSendPort(_receivePort.sendPort);

  @override
  StreamSubscription<T> listen(
    StreamDataListener<T> onData, {
    StreamErrorListener? onError,
    StreamOnDoneCallback? onDone,
    bool cancelOnError = false,
  }) {
    final subscription = _stream.listen(
      onData as StreamDataListener<dynamic>,
      onDone: onDone,
      onError: onError,
      cancelOnError: cancelOnError,
    ) as StreamSubscription<T>;
    return subscription;
  }

  @override
  Future<void> close() async => _receivePort.close();
}

/// Inner package factory
Out<T> createOut<T>() => OutNative<T>();
