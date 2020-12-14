import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'isolator.dart';

typedef Creator<TDataType> = void Function(BackendArgument<TDataType> argument);

mixin BackendMixin<TEventType> {
  bool _isInitialized = false;
  Stream<Message<TEventType, dynamic>> _fromBackend;
  Sender<TEventType, dynamic> _toBackend;
  StreamSubscription<Message<TEventType, dynamic>> _subscription;
  // final Queue<TEventType> operations = Queue();
  final Map<TEventType, Function> _eventsCallbacks = {};

  /// Method for creating disposable subscriptions
  void onEvent(TEventType event, Function func) {
    _eventsCallbacks[event] = func;
  }

  /// Method for creating backend of this frontend state
  @protected
  Future<void> initBackend<TDataType extends Object>(Creator<TDataType> creator, {TDataType data, ErrorHandler errorHandler}) async {
    final Communicator<TEventType, dynamic> communicator = await Isolator.isolate<TEventType, dynamic, TDataType>(
      creator,
      '${runtimeType.toString()}Backend',
      data: data,

      /// Error handler is a function for handle errors from backend on frontend (prefer to handle errors on backend)
      errorHandler: errorHandler,
    );
    _toBackend = communicator.toBackend;
    _fromBackend = communicator.fromBackend;
    await _subscription?.cancel();
    _subscription = _fromBackend.asBroadcastStream().listen(_responseFromBackendHandler);
    _isInitialized = true;
  }

  /// Method for sending event with any data to backend
  @protected
  void send<TValueType extends Object>(TEventType eventId, [TValueType value]) {
    assert(_isInitialized, 'You must call "initBackend" method before send data');
    final Message<TEventType, TValueType> message = Message(eventId, value);
    _toBackend.send(message);
  }

  /// Private backend's events handler, which run public handler and execute event's subscriptions
  void _responseFromBackendHandler(Message<TEventType, dynamic> message) {
    // operations.add(message.id);
    responseFromBackendHandler(message);
    if (_isMessageIdHasCallbacks(message.id)) {
      _eventsCallbacks[message.id]();
      _eventsCallbacks.remove(message.id);
    }
  }

  bool _isMessageIdHasCallbacks(TEventType id) => _eventsCallbacks.containsKey(id);

  /// Hook on every data, passed from backend to frontend
  @protected
  void onBackendResponse() {}

  /// Functions (tasks), which will executed by frontend on accordingly to  events from backend
  @protected
  Map<TEventType, Function> get tasks;

  /// Default handler of backend events
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
