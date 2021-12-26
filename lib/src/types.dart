library isolator;

import 'dart:async';

import 'package:isolator/src/backend/backend.dart';
import 'package:isolator/src/backend/backend_argument.dart';

/// Type for Backend actions, which will called by Frontend
typedef BackendAction<Event, Req, Res> = FutureOr<Res> Function({
  required Event event,
  required Req data,
});

/// Type for Frontend actions, which will handle Backend's messages
typedef FrontendAction<Event, Req, Res> = FutureOr<Res> Function({
  required Event event,
  required Req data,
});

/// Type for FrontendListener callback
typedef FrontendEventListener<Event> = FutureOr<void> Function(
  Event event,
);

/// Type of [Backend]'s initializer method
typedef BackendInitializer<T, B extends Backend> = B Function(
  BackendArgument<T> argument,
);

/// StreamDataListener
typedef StreamDataListener<T> = void Function(T data);

/// StreamErrorListener
typedef StreamErrorListener = Function;

/// StreamOnDoneCallback
typedef StreamOnDoneCallback = void Function();

/// IsolatePoolId
typedef IsolatePoolId = int;

/// BackendId
typedef BackendId = String;

/// Json
typedef Json = Map<String, dynamic>;

/// Caller<T>
typedef Caller<T> = T Function(dynamic object);

/// VoidCallback analog
typedef Callback = void Function();

/// Helper to import types
const int types = 1;
