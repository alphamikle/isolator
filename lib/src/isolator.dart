import 'dart:async';
import 'dart:isolate';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:isolator/src/utils.dart';

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

abstract class Backend<TEventType> {
  Backend(this._sendPortToFront)
      : _fromFront = ReceivePort(),
        senderToFront = Sender<TEventType, dynamic>(_sendPortToFront) {
    _fromFront.listen((dynamic val) => _messageHandler<dynamic>(val as Message<TEventType, dynamic>));
    _sendPortToFrontend();
    _initializerCompleter = Completer();
    init();
  }

  @protected
  final SendPort _sendPortToFront;
  @protected
  final Sender<TEventType, dynamic> senderToFront;
  @protected
  final ReceivePort _fromFront;
  @protected
  Map<TEventType, Function> get operations;

  bool _isInitialized = false;
  Completer<bool> _initializerCompleter;

  @protected
  @mustCallSuper
  Future<void> init() async {
    _isInitialized = true;
    _initializerCompleter.complete(true);
  }

  @protected
  void send<TValueType extends Object>(TEventType eventId, [TValueType value]) {
    final Message message = Message<TEventType, TValueType>(eventId, value);
    senderToFront.send(message);
  }

  void _sendPortToFrontend() {
    _sendPortToFront.send(_fromFront.sendPort);
  }

  Future<void> _messageHandler<TValueType>(Message<TEventType, TValueType> message) async {
    final TEventType id = message.id;
    final Function operation = operations[id];
    if (operation == null) {
      throw Exception('Operation for ID $id is not found in operations');
    }
    if (!_isInitialized) {
      await _initializerCompleter.future;
    }

    /// Example of function without params
    /// Closure: () => Future<String> from Function '_funcWithoutParams@266394741':.
    /// Example of function with params
    /// Closure: ([dynamic]) => Future<String> from Function '_funcWithParams@67394741':.
    final bool withParam = Utils.isFunctionWithParam(operation.toString());
    dynamic result;
    if (withParam) {
      result = await operation(message.value);
    } else {
      result = await operation();
    }
    if (result != null) {
      send<TValueType>(id, result);
    }
  }
}
