import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:isolator/next/action_reducer.dart';
import 'package:isolator/next/backend/backend_create_result.dart';
import 'package:isolator/next/backend/initializer_error_text.dart';
import 'package:isolator/next/in/in_abstract.dart';
import 'package:isolator/next/isolator/isolator_abstract.dart';
import 'package:isolator/next/maybe.dart';
import 'package:isolator/next/message.dart';
import 'package:isolator/next/out/out_abstract.dart';
import 'package:isolator/next/types.dart';
import 'package:isolator/src/utils.dart';

part 'frontend_action_initializer.dart';

mixin Frontend {
  void initActions();

  void onForceUpdate() {}

  void onEvent() {}

  @mustCallSuper
  Future<void> initBackend<T>({
    required BackendInitializer<T> initializer,
    required Type backendType,
    IsolatePoolId? poolId,
    T? data,
  }) async {
    initActions();
    final BackendCreateResult result = await Isolator.instance.isolate(
      initializer: initializer,
      backendType: backendType,
      poolId: poolId,
    );
    _backendOut = result.backendOut;
    _frontendIn = result.frontendIn;
    _backendOut.listen(_backendMessageRawHandler);
  }

  @mustCallSuper
  Future<void> dispose() async {
    await _backendOut.close();
    _completers.clear();
    _actions.clear();
  }

  Future<Maybe> run<Event, Request extends Object?>({required Event event, Request? data, Duration? timeout}) async {
    final String code = Utils.generateCode<dynamic>(event);
    final Completer<Maybe> completer = Completer<Maybe>();
    _completers[code] = completer;
    _frontendIn.send(
      Message<Event, Request?>(
        event: event,
        data: data,
        code: code,
        timestamp: DateTime.now(),
        serviceData: ServiceData.none,
      ),
    );
    Timer? timer;
    if (timeout != null) {
      timer = Timer(timeout, () {
        _completers.remove(code);
        throw Exception('Timeout ($timeout) of action $event with code $code exceed');
      });
    }
    final result = await completer.future;
    timer?.cancel();
    _completers.remove(code);
    return result;
  }

  FrontendActionInitializer<Event> on<Event>([Event? event]) => FrontendActionInitializer(frontend: this, event: event, eventType: Event);

  Future<void> _backendMessageRawHandler(dynamic backendMessage) async {
    if (backendMessage is Message) {
      await _backendMessageHandler<dynamic, dynamic>(backendMessage);
    } else {
      throw Exception('Got an invalid message from Backend: $backendMessage');
    }
  }

  Future<void> _backendMessageHandler<Event, Data>(Message<Event, Data> backendMessage) async {
    if (backendMessage.isChunksMessage) {
      await _handleChunksEvent<Event, dynamic>(backendMessage as Message<Event, List<dynamic>>);
    } else if (backendMessage.code.isNotEmpty) {
      await _handleSyncEvent<Event, Data>(backendMessage);
    } else {
      await _handleAsyncEvent<Event, Data>(backendMessage);
    }
  }

  Future<void> _handleSyncEvent<Event, Data>(Message<Event, Data> backendMessage) async {
    if (!_completers.containsKey(backendMessage.code)) {
      throw Exception('Not found Completer for event ${backendMessage.event} with code ${backendMessage.code}. Maybe you`ve seen Timeout exception?');
    }
    final data = backendMessage.data;
    final Completer<dynamic> completer = _completers[backendMessage.code]!;
    completer.complete(data);
    onEvent();
    if (backendMessage.forceUpdate) {
      onForceUpdate();
    }
  }

  Future<void> _handleAsyncEvent<Event, Data>(Message<Event, Data> backendMessage) async {
    final Function action = getAction(backendMessage.event, _actions, runtimeType.toString());
    action(event: backendMessage.event, data: backendMessage.data);
    onEvent();
    if (backendMessage.forceUpdate) {
      onForceUpdate();
    }
  }

  Future<void> _handleChunksEvent<Event, Data>(Message<Event, List<Data>> backendMessage) async {
    final String transactionCode = backendMessage.code;
    final ServiceData serviceData = backendMessage.serviceData;
    final List<Data> data = backendMessage.data;
    if (serviceData == ServiceData.transactionStart) {
      _chunksPartials[transactionCode] = data;
    } else if (serviceData == ServiceData.transactionContinue) {
      (_chunksPartials[transactionCode]! as List<Data>).addAll(data);
    } else if (serviceData == ServiceData.transactionEnd) {
      (_chunksPartials[transactionCode]! as List<Data>).addAll(data);
      final Message<Event, List<Data>> message = Message(
        event: backendMessage.event,
        data: _chunksPartials[transactionCode]! as List<Data>,
        code: '',
        timestamp: backendMessage.timestamp,
        serviceData: ServiceData.none,
      );
      await _backendMessageHandler(message);
      _chunksPartials.remove(transactionCode);
    } else if (serviceData == ServiceData.transactionAbort) {
      _chunksPartials.remove(transactionCode);
    }
  }

  late final Out _backendOut;
  late final In _frontendIn;
  final Map<dynamic, Function> _actions = <dynamic, Function>{};
  final Map<String, Completer> _completers = <String, Completer>{};
  final Map<String, List<dynamic>> _chunksPartials = {};
}
