import 'dart:async';
import 'dart:isolate';

import 'package:flutter/widgets.dart';

import 'isolator.dart';
import 'utils.dart';

abstract class Backend<TEventType> {
  Backend(this._sendPortToFront)
      : _fromFront = ReceivePort(),
        _senderToFront = Sender<TEventType, dynamic>(_sendPortToFront) {
    _fromFront.listen((dynamic val) => _messageHandler<dynamic>(val as Message<TEventType, dynamic>));
    _sendPortToFrontend();
    _initializerCompleter = Completer();
    init();
  }

  @protected
  final SendPort _sendPortToFront;
  @protected
  final Sender<TEventType, dynamic> _senderToFront;
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
  Future<void> handleErrors(TEventType event, dynamic error) async {}

  @protected
  void send<TValueType extends Object>(TEventType eventId, [TValueType value]) {
    final Message message = Message<TEventType, TValueType>(eventId, value);
    _senderToFront.send(message);
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
    try {
      if (withParam) {
        result = await operation(message.value);
      } else {
        result = await operation();
      }
    } catch (err) {
      await handleErrors(message.id, err);
      rethrow;
    }
    if (result != null) {
      send<TValueType>(id, result);
    }
  }
}
