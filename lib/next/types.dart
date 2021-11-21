import 'dart:async';

import 'package:isolator/next/backend/action_response.dart';
import 'package:isolator/next/backend/backend_argument.dart';

typedef BackendAction<Event, Req, Res> = FutureOr<ActionResponse<Res>> Function({required Event event, required Req data});
typedef BackendActionShort<Res> = FutureOr<ActionResponse<Res>> Function({dynamic event, dynamic data});
typedef FrontendAction<Event, Req, Res> = FutureOr<Res> Function({required Event event, required Req data});
typedef BackendInitializer<T, B> = B Function(BackendArgument<T> argument);
typedef StreamDataListener<T> = void Function(T data);
typedef StreamErrorListener = Function;
typedef StreamOnDoneCallback = void Function();
typedef IsolatePoolId = int;
typedef BackendId = String;
typedef Json = Map<String, dynamic>;
typedef Caller<T> = T Function(dynamic object);

const TYPES = 1;
