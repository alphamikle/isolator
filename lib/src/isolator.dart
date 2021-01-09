import 'dart:async';
import 'dart:isolate';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:isolator/src/utils.dart';

part 'backend.dart';
part 'config.dart';
part 'frontend.dart';
part 'packet.dart';

/// To describe errors handlers in [Frontend]
typedef FutureOr<T> ErrorHandler<T>(dynamic error);

class _Message<Id, Value extends Object> {
  factory _Message(Id id, [Value value, String code, bool isErrorMessage = false]) {
    return _Message._(id, value, code, DateTime.now(), isErrorMessage ?? false);
  }

  const _Message._(
    this.id,
    this.value,
    this.code,
    this.timestamp,
    this.isErrorMessage,
  );

  final Id id;
  final Value value;
  final String code;
  final DateTime timestamp;
  final bool isErrorMessage;

  @override
  String toString() => 'Message { id: $id; value: ${value ?? 'null'} }';
}

class Message<Id, Value extends Object> extends _Message {
  Message(Id id, [Value value]) : super._(id, value, null, DateTime.now(), false);
}

class _Sender<Id, Value> {
  _Sender(this._to);

  final SendPort _to;

  void send(_Message<Id, Value> message) {
    _to.send(message);
  }
}

class _Communicator<Id, Value> {
  _Communicator(this.fromBackend, this.toBackend);

  Stream<_Message<Id, Value>> fromBackend;
  _Sender<Id, Value> toBackend;
}

class BackendArgument<T extends Object> {
  const BackendArgument(this.toFrontend, [this.data, this.config]);

  final SendPort toFrontend;
  final T data;
  final Map<String, dynamic> config;
}

class Isolator {
  static final Map<String, Isolate> _isolates = {};

  static Future<_Communicator<Id, Value>> isolate<Id, Value, T extends Object>(
    ValueSetter<BackendArgument<T>> create,
    String isolateId, {
    IsolatorData<T> isolatorData,
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
    _isolates[isolateId] = await Isolate.spawn(create, BackendArgument<T>(receivePort.sendPort, isolatorData.data, isolatorData.config.toJson()), debugName: isolateId, errorsAreFatal: false);
    final Isolate isolate = _isolates[isolateId];
    final ReceivePort errorReceivePort = ReceivePort();

    /// messageAndStackTrace is a List<String> -> [message, stackStrace]
    errorReceivePort.listen((dynamic messageAndStackTrace) async {
      if (IsolatorConfig._instance.logEvents) {
        print('[ERROR] - [$isolateId] !!! The error was thrown in backend and got in Frontend');
      }
      if (errorHandler != null) {
        /// Use only error
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
