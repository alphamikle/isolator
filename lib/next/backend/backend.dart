library isolator;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:isolator/next/action_reducer.dart';
import 'package:isolator/next/backend/backend_argument.dart';
import 'package:isolator/next/backend/backend_init_result.dart';
import 'package:isolator/next/backend/initializer_error_text.dart';
import 'package:isolator/next/chunks.dart';
import 'package:isolator/next/in/in_abstract.dart';
import 'package:isolator/next/maybe.dart';
import 'package:isolator/next/message.dart';
import 'package:isolator/next/out/out_abstract.dart';
import 'package:isolator/next/out/out_native.dart';
import 'package:isolator/next/types.dart';
import 'package:isolator/src/utils.dart';

part '../chunks_delegate.dart';
part 'backend_action_initializer.dart';

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

  void send<Event>({required Event event, dynamic data, bool forceUpdate = false}) {
    // TODO(alphamikle): Handle Chunks
    _sentToFrontend<dynamic, dynamic>(
      Message<dynamic, dynamic>(
        event: event,
        data: data,
        code: '',
        serviceData: ServiceData.none,
        timestamp: DateTime.now(),
        forceUpdate: forceUpdate,
      ),
    );
  }

  Future<void> _frontendMessageRawHandler(dynamic frontendMessage) async {
    if (frontendMessage is Message) {
      await _frontendMessageHandler<dynamic, dynamic>(frontendMessage);
    } else {
      throw Exception('Got an invalid message from Frontend: $frontendMessage');
    }
  }

  Future<void> _frontendMessageHandler<Event, Data>(Message<Event, Data> message) async {
    final Function action = getAction(message.event, _actions, runtimeType.toString());
    late Maybe maybeResult;
    late dynamic result;
    try {
      final FutureOr<dynamic> compute = action(event: message.event, data: message.data);
      if (compute is Future) {
        result = await compute;
      } else {
        result = compute;
      }
      if (result is Chunks) {
        await _chunksDelegate.sendChunks<dynamic, dynamic>(chunks: result, event: message.event, code: message.code);
        return;
      }
      if (result is Iterable && result.length > 1000) {
        print('Maybe you send a very big response to Frontend? Let`s try [Chunks] wrapper');
      }
      maybeResult = Maybe(data: compute, error: null);
    } catch (error) {
      print('''
Got an error in backend action:
Action: "$action"
Event: "${message.event}"
Request Data: "${message.data}"
Service Data: "${message.serviceData}"
Error: "${error.toString()}"
Stacktrace: "${(error as dynamic).stackTrace?.toString()}"
''');
      maybeResult = Maybe(data: null, error: Error.safeToString(error));
    }
    _sentToFrontend<dynamic, dynamic>(
      Message<dynamic, dynamic>(
        event: message.event,
        data: maybeResult,
        code: message.code,
        timestamp: DateTime.now(),
        serviceData: ServiceData.none,
      ),
    );
  }

  Future<void> _dataBusMessageHandler(dynamic dataBusMessage) async {}

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
