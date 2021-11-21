import 'dart:async';
import 'dart:isolate';

import 'package:isolator/next/in/in_abstract.dart';
import 'package:isolator/next/in/in_native.dart';
import 'package:isolator/next/out/out_abstract.dart';
import 'package:isolator/next/types.dart';

class OutNative<T> implements Out<T> {
  late final ReceivePort _receivePort = ReceivePort();
  late final Stream<dynamic> _stream = _receivePort.asBroadcastStream();

  @override
  In get createIn => InNative()..initSendPort(_receivePort.sendPort);

  @override
  StreamSubscription<T> listen(StreamDataListener<T> onData, {StreamErrorListener? onError, StreamOnDoneCallback? onDone, bool cancelOnError = false}) {
    final StreamSubscription<T> subscription = _stream.listen(
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

Out<T> createOut<T>() => OutNative<T>();
