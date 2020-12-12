import 'dart:async';
import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'isolator.dart';

typedef Creator<TDataType> = void Function(BackendArgument<TDataType> argument);

mixin BackendMixin<TEventType> {
  bool _isInitialized = false;
  Stream<Message<TEventType, dynamic>> _fromBackend;
  Sender<TEventType, dynamic> _toBackend;
  StreamSubscription<Message<TEventType, dynamic>> _subscription;
  final Queue<TEventType> operations = Queue();
  final Map<TEventType, Function> _eventsCallbacks = {};

  void onEvent(TEventType event, Function func) {
    _eventsCallbacks[event] = func;
  }

  @protected
  Future<void> initBackend<TDataType extends Object>(Creator<TDataType> creator, {TDataType data}) async {
    final Communicator<TEventType, dynamic> communicator = await Isolator.isolate<TEventType, dynamic, TDataType>(creator, '${runtimeType.toString()}Backend', data);
    _toBackend = communicator.toBackend;
    _fromBackend = communicator.fromBackend;
    await _subscription?.cancel();
    _subscription = _fromBackend.asBroadcastStream().listen(_responseFromBackendHandler);
    _isInitialized = true;
  }

  @protected
  void send<TValueType extends Object>(TEventType eventId, [TValueType value]) {
    assert(_isInitialized, 'You must call "initBackend" method before send data');
    final Message<TEventType, TValueType> message = Message(eventId, value);
    _toBackend.send(message);
  }

  void _responseFromBackendHandler(Message<TEventType, dynamic> message) {
    operations.add(message.id);
    responseFromBackendHandler(message);
    if (_isMessageIdHasCallbacks(message.id)) {
      _eventsCallbacks[message.id]();
      _eventsCallbacks.remove(message.id);
    }
  }

  bool _isMessageIdHasCallbacks(TEventType id) => _eventsCallbacks.containsKey(id);

  @protected
  void onBackendResponse() {}

  @protected
  Map<TEventType, Function> get tasks;

  @protected
  void responseFromBackendHandler(Message<TEventType, dynamic> message) {
    final Function task = tasks[message.id];
    if (task != null) {
      if (message.value != null) {
        task(message.value);
      } else {
        task();
      }
    }
    onBackendResponse();
  }
}
