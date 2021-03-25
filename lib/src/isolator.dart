import 'dart:async';
import 'dart:isolate';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:isolator/src/utils.dart';

part 'backend.dart';
part 'backend_chunk_mixin.dart';
part 'backend_init_mixin.dart';
part 'backend_on_error_mixin.dart';
part 'backend_sync_mixin.dart';
part 'config.dart';
part 'frontend.dart';
part 'logger.dart';
part 'message_bus_backend.dart';
part 'message_bus_frontend.dart';
part 'packet.dart';

/// To describe errors handlers in [Frontend]
typedef FutureOr<T> ErrorHandler<T>(dynamic error);

enum _ServiceParam {
  startChunkTransaction,
  startChunkTransactionWithUpdate,
  chunkPiece,
  endChunkTransaction,
  cancelTransaction,
  error,
  anotherBackendMethodRequest,
  anotherBackendMethodResponse,
}

class _Message<Id, Value> {
  factory _Message(Id id, {Value? value, String? code, _ServiceParam? serviceParam}) {
    return _Message._(id, value, code, DateTime.now(), serviceParam);
  }

  const _Message._(
    this.id,
    this.value,
    this.code,
    this.timestamp,
    this.serviceParam,
  );

  final Id id;
  final Value? value;
  final String? code;
  final DateTime timestamp;
  final _ServiceParam? serviceParam;

  bool get isErrorMessage => serviceParam == _ServiceParam.error;
  bool get isStartOfTransaction => serviceParam == _ServiceParam.startChunkTransaction || serviceParam == _ServiceParam.startChunkTransactionWithUpdate;
  bool get withUpdate => serviceParam == _ServiceParam.startChunkTransactionWithUpdate;
  bool get isCancelingOfTransaction => serviceParam == _ServiceParam.cancelTransaction;
  bool get isTransferencePieceOfTransaction => serviceParam == _ServiceParam.chunkPiece;
  bool get isEndOfTransaction => serviceParam == _ServiceParam.endChunkTransaction;

  @override
  String toString() => 'Message { id: $id; value: ${value ?? 'null'} }';
}

class Message<Id, Value> extends _Message {
  Message(Id id, [Value? value]) : super._(id, value, null, DateTime.now(), null);
}

/// Type for sending messages from one of Backends to all others
class Broadcast {}

class _Sender<Id, Value> {
  _Sender(this._to);

  final SendPort _to;

  SendPort get sendPort => _to;

  void send(_Message<Id, Value?> message) {
    _to.send(message);
  }
}

class _Communicator<Id, Value> {
  _Communicator(this.fromBackend, this.toBackend);

  Stream<_Message<Id, Value>> fromBackend;
  _Sender<Id, Value> toBackend;
}

class BackendArgument<T> {
  const BackendArgument(this.toFrontend, {this.data, required this.config, this.messageBusSendPort});

  final SendPort toFrontend;
  final T? data;
  final Map<String, dynamic> config;
  final SendPort? messageBusSendPort;
}

class Isolator {
  static final Map<String, Isolate> _isolates = {};
  static bool _isMessageBusCreated = false;
  static late SendPort _messageBusBackendSendPort;
  static late MessageBusFrontend _messageBusFrontend;

  static Future<_Communicator<Id, Value>> isolate<Id, Value, T>(
    ValueSetter<BackendArgument<T>> create,
    String isolateId, {
    required IsolatorData<T> isolatorData,
    ErrorHandler? errorHandler,
    bool isMessageBus = false,
  }) async {
    // create message bus on first isolator init
    if (!_isMessageBusCreated) {
      _isMessageBusCreated = true;
      await _createMessageBus();
    }
    final Completer<_Communicator<Id, Value>> completer = Completer();
    final ReceivePort receivePort = ReceivePort();
    final SendPort sendPort = receivePort.sendPort;
    final Stream<dynamic> receiveBroadcast = receivePort.asBroadcastStream();
    final StreamSubscription<dynamic> subscription = receiveBroadcast.listen((dynamic message) {
      if (message is Packet2<SendPort, SendPort?>) {
        if (message.value2 != null) {
          _messageBusFrontend.addIsolateSendPort(Packet2(isolateId, message.value2!));
        }
        completer.complete(
          _Communicator<Id, Value>(
            Stream.castFrom<dynamic, _Message<Id, Value>>(receiveBroadcast),
            _Sender<Id, Value>(message.value),
          ),
        );
      }
    });
    _isolates[isolateId]?.kill();
    _isolates[isolateId] = await Isolate.spawn(
      create,
      BackendArgument<T>(sendPort, data: isolatorData.data, config: isolatorData.config.toJson(), messageBusSendPort: isMessageBus ? null : _messageBusBackendSendPort),
      debugName: isolateId,
      errorsAreFatal: false,
    );

    final Isolate isolate = _isolates[isolateId]!;
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

  static Future<void> _createMessageBus() async {
    final MessageBusFrontend messageBusFrontend = MessageBusFrontend();
    await messageBusFrontend.init();
    _messageBusBackendSendPort = messageBusFrontend.getMessageBusSendPort();
    _messageBusFrontend = messageBusFrontend;
  }

  static String generateBackendId(Type backendType) {
    return '${backendType}Backend';
  }

  static void kill(String isolateId) {
    if (_isolates[isolateId] != null) {
      _isolates[isolateId]!.kill();
      _isolates.remove(isolateId);
    }
  }
}
