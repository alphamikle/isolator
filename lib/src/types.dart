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
typedef FrontendEventListener<Event> = FutureOr<void> Function(Event event);
typedef BackendInitializer<T, B extends Backend> = B Function(BackendArgument<T> argument);
typedef StreamDataListener<T> = void Function(T data);
typedef StreamErrorListener = Function;
typedef StreamOnDoneCallback = void Function();
typedef IsolatePoolId = int;
typedef BackendId = String;
typedef Json = Map<String, dynamic>;
typedef Caller<T> = T Function(dynamic object);

const int types = 1;
