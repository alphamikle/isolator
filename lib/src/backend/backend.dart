library isolator;

import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:isolator/src/action_reducer.dart';
import 'package:isolator/src/backend/action_response.dart';
import 'package:isolator/src/backend/backend_argument.dart';
import 'package:isolator/src/backend/backend_init_result.dart';
import 'package:isolator/src/backend/child_backend_closer.dart';
import 'package:isolator/src/backend/child_backend_initializer.dart';
import 'package:isolator/src/backend/chunks.dart';
import 'package:isolator/src/backend/initializer_error_text.dart';
import 'package:isolator/src/data_bus/data_bus_request.dart';
import 'package:isolator/src/data_bus/data_bus_response.dart';
import 'package:isolator/src/in/in_abstract.dart';
import 'package:isolator/src/maybe.dart';
import 'package:isolator/src/message.dart';
import 'package:isolator/src/out/out_abstract.dart';
import 'package:isolator/src/tools/helpers.dart';
import 'package:isolator/src/tools/utils.dart';
import 'package:isolator/src/transporter/container.dart';
import 'package:isolator/src/transporter/transporter.dart'
    if (dart.library.isolate) 'package:isolator/src/transporter/transporter_native.dart'
    if (dart.library.js) 'package:isolator/src/transporter/transporter_web.dart';
import 'package:isolator/src/types.dart';

part 'backend_action_initializer.dart';
part 'chunks_delegate.dart';
part 'interactor.dart';

abstract class Backend {
  Backend({required BackendArgument argument})
      : _toFrontendIn = argument.toFrontendIn,
        _toDataBusIn = argument.toDataBusIn {
    _fromFrontendOut.listen(_frontendMessageRawHandler);
    _fromDataBusOut.listen(_dataBusMessageHandler);
    _sendMineInsBack();
    initActions();
  }

  @protected
  void initActions();

  @protected
  BackendActionInitializer<Event> whenEventCome<Event>([Event? event]) => BackendActionInitializer(backend: this, event: event, eventType: Event);

  @protected
  Future<void> send<Event, Data>({required Event event, ActionResponse<Data>? data, bool forceUpdate = false, bool sendDirectly = false}) async {
    if (data == null || data.isEmpty) {
      _sentToFrontend(
        Message<Event, Data?>(
          event: event,
          data: null,
          code: '',
          serviceData: ServiceData.none,
          timestamp: DateTime.now(),
          forceUpdate: forceUpdate,
        ),
        sendDirectly: sendDirectly,
      );
    } else if (data.isList) {
      _sentToFrontend(
        Message<Event, List<Data>>(
          event: event,
          data: data.list,
          code: '',
          serviceData: ServiceData.none,
          timestamp: DateTime.now(),
          forceUpdate: forceUpdate,
        ),
        sendDirectly: sendDirectly,
      );
    } else if (data.isValue) {
      _sentToFrontend(
        Message<Event, Data>(
          event: event,
          data: data.value,
          code: '',
          serviceData: ServiceData.none,
          timestamp: DateTime.now(),
          forceUpdate: forceUpdate,
        ),
        sendDirectly: sendDirectly,
      );
    } else if (data.isChunks) {
      await _chunksDelegate.sendChunks(
        chunks: data.chunks,
        event: event,
        code: event.toString(),
      );
    }
  }

  Future<void> _frontendMessageRawHandler(dynamic frontendMessage) async {
    if (frontendMessage is Message) {
      await _frontendMessageHandler<dynamic, dynamic, dynamic>(frontendMessage);
    } else if (frontendMessage is ChildBackendInitializer) {
      final Backend childBackend = frontendMessage.initializer(frontendMessage.argument);
      _childBackends[frontendMessage.backendId] = childBackend;
    } else if (frontendMessage is ChildBackendCloser) {
      _childBackends.remove(frontendMessage.backendId);
    } else {
      throw Exception('Got an invalid message from Frontend: ${objectToTypedString(frontendMessage)}');
    }
  }

  Future<void> _frontendMessageHandler<Event, Req, Res>(Message<Event, Req> message) async {
    final action = getAction(message.event, _actions, runtimeType.toString());
    late Maybe<Res> maybeResult;
    late ActionResponse<Res> result;
    try {
      final FutureOr<ActionResponse<Res>> compute = action(event: message.event, data: message.data) as FutureOr<ActionResponse<Res>>;
      if (compute is Future) {
        result = await compute;
      } else {
        result = compute;
      }
      if (result.isChunks) {
        await _chunksDelegate.sendChunks<Event, Res>(
          chunks: result.chunks,
          event: message.event,
          code: messageCodeToSyncChunkCode(message.code),
        );
        return;
      }
      if (result.isList) {
        if (result.list.length > 100) {
          print('Maybe you send a very big response to Frontend? Let`s try [Chunks] wrapper');
        }
        maybeResult = Maybe<Res>(data: result.list, error: null);
      } else if (result.isValue) {
        maybeResult = Maybe<Res>(data: result.value, error: null);
      } else if (result.isEmpty) {
        maybeResult = Maybe<Res>(data: null, error: null);
      }
    } catch (error) {
      result = ActionResponse.empty();
      maybeResult = Maybe(data: null, error: error);
      print('''
Got an error in backend action:
Action: "$action"
Event: "${message.event}"
Result: "$result"
Request Data: "${message.data}"
Service Data: "${message.serviceData}"
Error: "${errorToString(error)}"
Stacktrace: "${errorStackTraceToString(error)}"
''');
    }
    _sentToFrontend<Event, Maybe<Res>>(
      Message<Event, Maybe<Res>>(
        event: message.event,
        data: maybeResult,
        code: message.code,
        timestamp: DateTime.now(),
        serviceData: ServiceData.none,
      ),
    );
  }

  Future<void> _dataBusMessageHandler(dynamic dataBusMessage) async {
    if (dataBusMessage is DataBusRequest) {
      await _dataBusRequestHandler<dynamic, dynamic, dynamic>(dataBusMessage);
    } else if (dataBusMessage is DataBusResponse) {
      await _dataBusResponseHandler<dynamic, dynamic>(dataBusMessage);
    } else {
      throw UnimplementedError('Incorrect message from DataBus: ${objectToTypedString(dataBusMessage)}');
    }
  }

  Future<void> _dataBusRequestHandler<Event, Data, Res>(DataBusRequest<Event, Data> request) async {
    final action = getAction(request.event, _actions, runtimeType.toString());
    late Maybe<Res> maybeResult;
    late ActionResponse<Res> result;
    try {
      final FutureOr<ActionResponse<Res>> compute = action(event: request.event, data: request.data) as FutureOr<ActionResponse<Res>>;
      if (compute is Future) {
        result = await compute;
      } else {
        result = compute;
      }
      if (result.isChunks) {
        maybeResult = Maybe<Res>(data: result.chunks.data, error: null);
      } else if (result.isList) {
        maybeResult = Maybe<Res>(data: result.list, error: null);
      } else if (result.isValue) {
        maybeResult = Maybe<Res>(data: result.value, error: null);
      } else if (result.isEmpty) {
        maybeResult = Maybe<Res>(data: null, error: null);
      }
    } catch (error) {
      result = ActionResponse.empty();
      maybeResult = Maybe(data: null, error: Error.safeToString(error));
      print('''
Got an error in backend DataBus request handler:
Action: "$action"
Event: "${request.event}"
Result: "$result"
Request Data: "${request.data}"
Request from: "${request.from}"
Error: "${errorToString(error)}"
Stacktrace: "${errorStackTraceToString(error)}"
''');
    }
    _sendResponseToBackend<Event, Res>(
      DataBusResponse<Event, Res>(
        event: request.event,
        data: maybeResult,
        to: request.from,
        from: request.to,
        id: request.id,
      ),
    );
  }

  Future<void> _dataBusResponseHandler<Event, Data>(DataBusResponse<Event, Data> request) async {
    final Completer<Maybe<dynamic>>? completer = _anotherBackendsActionsCompleters[request.id];
    if (completer == null) {
      throw Exception('Not fount Completer with these params: From: ${request.from}; To ${request.to}; ID: ${request.id}; Data: ${request.data}');
    }
    completer.complete(request.data);
  }

  void _sendMineInsBack() {
    _toFrontendIn.send(
      BackendInitResult(
        frontendToBackendIn: _fromFrontendOut.createIn,
        dataBusToBackendIn: _fromDataBusOut.createIn,
        timestamp: DateTime.now(),
      ),
    );
  }

  void _sentToFrontend<Event, Data>(Message<Event, Data> message, {bool sendDirectly = false}) =>
      sendThroughTransporter<Event, Data>(Container(toFrontendIn: _toFrontendIn, message: message), sendDirectly: sendDirectly);

  Future<Maybe<Res>> _sendRequestToBackend<Event, Req, Res>(DataBusRequest<Event, Req> request) async {
    final Completer<Maybe<dynamic>> anotherBackendActionCompleter = Completer<Maybe<dynamic>>();
    _anotherBackendsActionsCompleters[request.id] = anotherBackendActionCompleter;
    _toDataBusIn.send(request);
    final Maybe<dynamic> response = await anotherBackendActionCompleter.future;
    return response.castTo();
  }

  void _sendResponseToBackend<Event, Data>(DataBusResponse<Event, Data> response) {
    _toDataBusIn.send(response);
  }

  final Map<dynamic, Function> _actions = <dynamic, Function>{};
  final Map<String, Completer<Maybe<dynamic>>> _anotherBackendsActionsCompleters = {};
  late final Out _fromFrontendOut = Out.create<dynamic>();
  late final Out _fromDataBusOut = Out.create<dynamic>();
  final In _toFrontendIn;
  final In _toDataBusIn;
  late final ChunksDelegate _chunksDelegate = ChunksDelegate(backend: this);
  final Map<String, Backend> _childBackends = {};
}
