import 'dart:async';

import 'package:isolator/next/backend/backend_argument.dart';

typedef BackendAction<Event, Request, Response> = FutureOr<Response> Function({required Event event, required Request data});
typedef FrontendAction<Event, Request, Response> = FutureOr<Response> Function({required Event event, required Request data});
typedef BackendInitializer<T> = void Function(BackendArgument<T> argument);
typedef StreamDataListener<T> = void Function(T data);
typedef StreamErrorListener = Function;
typedef StreamOnDoneCallback = void Function();
typedef IsolatePoolId = int;
typedef BackendId = String;
typedef Json = Map<String, dynamic>;
typedef Caller<T> = T Function(dynamic object);

const TPS = 1;
