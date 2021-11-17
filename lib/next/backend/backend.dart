library isolator;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:isolator/next/action_reducer.dart';
import 'package:isolator/next/backend/action_response.dart';
import 'package:isolator/next/backend/backend_argument.dart';
import 'package:isolator/next/backend/backend_init_result.dart';
import 'package:isolator/next/backend/chunks.dart';
import 'package:isolator/next/backend/initializer_error_text.dart';
import 'package:isolator/next/in/in_abstract.dart';
import 'package:isolator/next/maybe.dart';
import 'package:isolator/next/message.dart';
import 'package:isolator/next/out/out_abstract.dart';
import 'package:isolator/next/out/out_native.dart';
import 'package:isolator/next/types.dart';
import 'package:isolator/next/utils.dart';
import 'package:isolator/src/utils.dart';

part 'backend_action_initializer.dart';
part 'chunks_delegate.dart';

abstract class Backend {
  Backend({required BackendArgument argument})
      : _toFrontendIn = argument.toFrontendIn,
        _toDataBusIn = argument.toDataBusIn {
    _fromFrontendOut.listen(_frontendMessageRawHandler);
    _fromDataBusOut.listen(_dataBusMessageHandler);
    _sendMinePortsBack();
    initActions();
  }

  late final Out _fromFrontendOut = OutNative<dynamic>();
  late final Out _fromDataBusOut = OutNative<dynamic>();
  final In _toFrontendIn;
  final In _toDataBusIn;
  late final ChunksDelegate _chunksDelegate = ChunksDelegate(backend: this);

  void initActions();

  BackendActionInitializer<Event> on<Event>([Event? event]) => BackendActionInitializer(backend: this, event: event, eventType: Event);

  Future<void> send<Event, Data>({required Event event, ActionResponse<Data>? data, bool forceUpdate = false}) async {
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
      );
    } else if (data.isList) {
      _sentToFrontend(
        Message<Event, List<Data>>(
          event: event,
          data: data.list as List<Data>,
          code: '',
          serviceData: ServiceData.none,
          timestamp: DateTime.now(),
          forceUpdate: forceUpdate,
        ),
      );
    } else if (data.isValue) {
      _sentToFrontend(
        Message<Event, Data>(
          event: event,
          data: data.value as Data,
          code: '',
          serviceData: ServiceData.none,
          timestamp: DateTime.now(),
          forceUpdate: forceUpdate,
        ),
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
    } else {
      throw Exception('Got an invalid message from Frontend: $frontendMessage');
    }
  }

  Future<void> _frontendMessageHandler<Event, Req, Res>(Message<Event, Req> message) async {
    final Function action = getAction(message.event, _actions, runtimeType.toString());
    late Maybe maybeResult;
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
          code: convertMessageCodeToSyncChunkEventCode(message.code),
        );
        return;
      }
      if (result.isList) {
        if (result.list.length > 100) {
          print('Maybe you send a very big response to Frontend? Let`s try [Chunks] wrapper');
        }
        maybeResult = Maybe(data: result.list, error: null);
      } else if (result.isValue) {
        maybeResult = Maybe(data: result.value, error: null);
      } else if (result.isEmpty) {
        maybeResult = const Maybe(data: null, error: null);
      }
    } catch (error) {
      result = ActionResponse.empty();
      maybeResult = Maybe(data: null, error: Error.safeToString(error));
      print('''
Got an error in backend action:
Action: "$action"
Event: "${message.event}"
Result: "$result"
Request Data: "${message.data}"
Service Data: "${message.serviceData}"
Error: "${error.toString()}"
Stacktrace: "${(error as dynamic).stackTrace?.toString()}"
''');
    }
    _sentToFrontend<Event, Maybe>(
      Message<Event, Maybe>(
        event: message.event,
        data: maybeResult,
        code: message.code,
        timestamp: DateTime.now(),
        serviceData: ServiceData.none,
      ),
    );
  }

  Future<void> _dataBusMessageHandler(dynamic dataBusMessage) async {
    // TODO(alphamikle): Complete this method
  }

  void _sendMinePortsBack() {
    _toFrontendIn.send(
      BackendInitResult(
        frontendToBackendIn: _fromFrontendOut.createIn,
        dataBusToBackendIn: _fromDataBusOut.createIn,
        timestamp: DateTime.now(),
      ),
    );
  }

  void _sentToFrontend<Event, Data>(Message<Event, Data> message) => _toFrontendIn.send(message);

  final Map<dynamic, Function> _actions = <dynamic, Function>{};
}
