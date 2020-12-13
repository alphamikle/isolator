import 'dart:async';
import 'dart:isolate';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

typedef ExceptionHandler = Future<void> Function(dynamic exception);

class Message<Id, Value extends Object> {
  const Message(this.id, [this.value]);
  final Id id;
  final Value value;

  @override
  String toString() => 'Message { id: $id; value: ${value ?? 'null'} }';
}

class Sender<Id, Value> {
  Sender(this._to);

  final SendPort _to;

  void send(Message<Id, Value> message) {
    _to.send(message);
  }
}

class BackendArgument<T extends Object> {
  const BackendArgument(this.toFrontend, [this.data]);

  final SendPort toFrontend;
  final T data;
}

class Communicator<Id, Value> {
  Communicator(this.fromBackend, this.toBackend);

  Stream<Message<Id, Value>> fromBackend;
  Sender<Id, Value> toBackend;
}

class Isolator {
  static final Map<String, Isolate> _isolates = {};
  // static final Queue<Isolate> _isolatesQueue = Queue();

  static Future<Communicator<Id, Value>> isolate<Id, Value, T extends Object>(ValueSetter<BackendArgument<T>> create, String isolateId, [T data]) async {
    final Completer<Communicator<Id, Value>> completer = Completer();
    final ReceivePort receivePort = ReceivePort();
    final Stream<dynamic> receiveBroadcast = receivePort.asBroadcastStream();
    final StreamSubscription<dynamic> subscription = receiveBroadcast.listen((dynamic message) {
      if (message is SendPort) {
        completer.complete(Communicator<Id, Value>(Stream.castFrom<dynamic, Message<Id, Value>>(receiveBroadcast), Sender<Id, Value>(message)));
      }
    });
    _isolates[isolateId]?.kill();
    _isolates[isolateId] = await Isolate.spawn(create, BackendArgument<T>(receivePort.sendPort, data), debugName: isolateId);
    final Isolate isolate = _isolates[isolateId];
    isolate.setErrorsFatal(false);
    final ReceivePort errorReceivePort = ReceivePort();

    // TODO: Handle errors on frontend
    /// messageAndStackTrace is a List<String> -> [message, stackStrace]
    errorReceivePort.listen((dynamic messageAndStackTrace) {
      throw messageAndStackTrace;
    });
    isolate.addErrorListener(errorReceivePort.sendPort);
    final Communicator<Id, Value> communicator = await completer.future;
    await subscription.cancel();
    return communicator;
  }
}
