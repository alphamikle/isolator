import 'dart:async';
import 'dart:isolate';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

part 'backend.dart';
part 'backend_mixin.dart';
part 'packet.dart';
part 'utils.dart';

typedef ErrorHandler = Future<void> Function(dynamic error);

class _Message<Id, Value extends Object> {
  const _Message(this.id, [this.value, this.code]);
  final Id id;
  final Value value;
  final String code;

  @override
  String toString() => 'Message { id: $id; value: ${value ?? 'null'} }';
}

class _Sender<Id, Value> {
  _Sender(this._to);

  final SendPort _to;

  void send(_Message<Id, Value> message) {
    _to.send(message);
  }
}

class BackendArgument<T extends Object> {
  const BackendArgument(this.toFrontend, [this.data]);

  final SendPort toFrontend;
  final T data;
}

class _Communicator<Id, Value> {
  _Communicator(this.fromBackend, this.toBackend);

  Stream<_Message<Id, Value>> fromBackend;
  _Sender<Id, Value> toBackend;
}

class Isolator {
  static final Map<String, Isolate> _isolates = {};
  // static final Queue<Isolate> _isolatesQueue = Queue();

  static Future<_Communicator<Id, Value>> isolate<Id, Value, T extends Object>(
    ValueSetter<BackendArgument<T>> create,
    String isolateId, {
    T data,
    ErrorHandler errorHandler,
  }) async {
    final Completer<_Communicator<Id, Value>> completer = Completer();
    final ReceivePort receivePort = ReceivePort();
    final Stream<dynamic> receiveBroadcast = receivePort.asBroadcastStream();
    final StreamSubscription<dynamic> subscription = receiveBroadcast.listen((dynamic message) {
      if (message is SendPort) {
        completer.complete(_Communicator<Id, Value>(Stream.castFrom<dynamic, _Message<Id, Value>>(receiveBroadcast), _Sender<Id, Value>(message)));
      }
    });
    _isolates[isolateId]?.kill();
    _isolates[isolateId] = await Isolate.spawn(create, BackendArgument<T>(receivePort.sendPort, data), debugName: isolateId);
    final Isolate isolate = _isolates[isolateId];
    isolate.setErrorsFatal(false);
    final ReceivePort errorReceivePort = ReceivePort();

    // TODO: Handle errors on frontend
    /// messageAndStackTrace is a List<String> -> [message, stackStrace]
    errorReceivePort.listen((dynamic messageAndStackTrace) async {
      if (errorHandler != null) {
        // Use only error
        await errorHandler(messageAndStackTrace[0]);
      }
      throw messageAndStackTrace;
    });
    isolate.addErrorListener(errorReceivePort.sendPort);
    final _Communicator<Id, Value> communicator = await completer.future;
    await subscription.cancel();
    return communicator;
  }
}
