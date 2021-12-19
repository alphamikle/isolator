import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:isolator/next/action_reducer.dart';
import 'package:isolator/next/backend/backend.dart';
import 'package:isolator/next/backend/backend_create_result.dart';
import 'package:isolator/next/backend/initializer_error_text.dart';
import 'package:isolator/next/frontend/frontend_event_subscription.dart';
import 'package:isolator/next/in/in_abstract.dart';
import 'package:isolator/next/isolator/isolator_abstract.dart';
import 'package:isolator/next/maybe.dart';
import 'package:isolator/next/message.dart';
import 'package:isolator/next/out/out_abstract.dart';
import 'package:isolator/next/types.dart';
import 'package:isolator/next/utils.dart';

part 'frontend_action_initializer.dart';
part 'frontend_action_subscriber.dart';

mixin Frontend {
  @protected
  void initActions();

  @protected
  void onForceUpdate() {}

  @protected
  void onEveryEvent() {}

  @protected
  bool get updateOnEveryEvent => false;

  @protected
  Future<Maybe<Res>> run<Event, Req extends Object?, Res extends Object?>({required Event event, Req? data, Duration? timeout, bool trackTime = false}) async {
    final String code = generateMessageCode(event);
    final Completer<Maybe<dynamic>> completer = Completer<Maybe<dynamic>>();
    final StackTrace currentTrace = StackTrace.current;
    final String runningFunctionName = getNameOfParentRunningFunction(currentTrace.toString());
    _completers[code] = completer;
    _runningFunctions[code] = runningFunctionName;
    if (trackTime) {
      _timeTrackers[code] = DateTime.now();
    }
    _frontendIn.send(
      Message<Event, Req?>(
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
        _runningFunctions.remove(code);
        throw Exception('Timeout ($timeout) of action $event with code $code exceed');
      });
    }
    final Maybe<dynamic> result = await completer.future;
    timer?.cancel();
    _completers.remove(code);
    _runningFunctions.remove(code);
    return result.castTo<Res>();
  }

  @protected
  FrontendActionInitializer<Event> whenEventCome<Event>([Event? event]) => FrontendActionInitializer(frontend: this, event: event, eventType: Event);

  FrontendEventSubscription<Event> subscribeOnEvent<Event>({
    required FrontendEventListener<Event> listener,

    /// Will called only once and automatically closed
    bool single = false,

    /// If true - this listener will been called on every action with this event
    /// If false - only on forceUpdate (if these events will be)
    bool onEveryEvent = false,
    Event? event,
  }) {
    return FrontendActionSubscriber(frontend: this, event: event, eventType: Event).subscribe(
      single: single,
      listener: listener,
      onEveryEvent: onEveryEvent,
    );
  }

  @mustCallSuper
  Future<void> initBackend<T, B extends Backend>({
    required BackendInitializer<T, B> initializer,
    IsolatePoolId? poolId,
    T? data,
  }) async {
    initActions();
    final BackendCreateResult result = await Isolator.instance.isolate(
      initializer: initializer,
      poolId: poolId,
    );
    _backendType = B;
    _poolId = result.poolId;
    _backendOut = result.backendOut;
    _frontendIn = result.frontendIn;
    _backendOut.listen(_backendMessageRawHandler);
  }

  @mustCallSuper
  Future<void> destroy() async {
    _completers.clear();
    _runningFunctions.clear();
    _actions.clear();
    await Isolator.instance.close(backendType: _backendType, poolId: _poolId);
  }

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
    _handleListeners(backendMessage.event);
  }

  Future<void> _handleSyncEvent<Event, Data>(Message<Event, Data> backendMessage) async {
    final String code = backendMessage.code;
    try {
      if (!_completers.containsKey(code)) {
        throw Exception('Not found Completer for event ${backendMessage.event} with code $code. Maybe you`ve seen Timeout exception?');
      }
      final Data data = backendMessage.data;
      final Completer<Data> completer = _completers[code]! as Completer<Data>;
      completer.complete(data);
      onEveryEvent();
      if (backendMessage.forceUpdate || updateOnEveryEvent) {
        onForceUpdate();
      }
    } catch (error) {
      print('''
[$runtimeType] Sync action error
Data: ${objectToTypedString(backendMessage.data)}
Event: ${objectToTypedString(backendMessage.event)}
Code: ${backendMessage.code}
Additional info: ${_runningFunctions[code] ?? StackTrace.current}
Error: ${errorToString(error)}
Stacktrace: ${errorStackTraceToString(error)}
''');
      _runningFunctions.remove(code);
      rethrow;
    }
    _trackTime(code, backendMessage);
  }

  Future<void> _handleAsyncEvent<Event, Data>(Message<Event, Data> backendMessage) async {
    try {
      final Function action = getAction(backendMessage.event, _actions, runtimeType.toString());
      action(event: backendMessage.event, data: backendMessage.data);
      onEveryEvent();
      if (backendMessage.forceUpdate || updateOnEveryEvent) {
        onForceUpdate();
      }
    } catch (error) {
      print('''
[$runtimeType] Async action error
Data: ${objectToTypedString(backendMessage.data)}
Event: ${objectToTypedString(backendMessage.event)}
Code: ${backendMessage.code}
Additional info: ${_runningFunctions[backendMessage.code] ?? StackTrace.current}
Error: ${errorToString(error)}
Stacktrace: ${errorStackTraceToString(error)}
''');
      _runningFunctions.remove(backendMessage.code);
      rethrow;
    }
    _trackTime(backendMessage.code, backendMessage);
  }

  Future<void> _handleChunksEvent<Event, Data>(Message<Event, List<Data>> backendMessage) async {
    final String transactionCode = backendMessage.code;
    final ServiceData serviceData = backendMessage.serviceData;
    final List<Data> data = backendMessage.data;
    print('''
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
TRANSACTION:
EVENT: ${backendMessage.event}
SERVICE INFO: ${backendMessage.serviceData}
HASH: ${backendMessage.code}
ITEMS PER MESSAGE: ${backendMessage.data.length}
TIME: ${backendMessage.timestamp.toIso8601String()}
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<''');
    if (serviceData == ServiceData.transactionStart) {
      _chunksPartials[transactionCode] = data;
    } else if (serviceData == ServiceData.transactionContinue) {
      (_chunksPartials[transactionCode]! as List<Data>).addAll(data);
    } else if (serviceData == ServiceData.transactionEnd) {
      (_chunksPartials[transactionCode]! as List<Data>).addAll(data);
      final bool isSyncChunkEvent = isSyncChunkEventCode(backendMessage.code);
      if (isSyncChunkEvent) {
        await _handleSyncEvent(
          Message(
            event: backendMessage.event,
            data: Maybe<Data>(data: _chunksPartials[transactionCode], error: null),
            code: syncChunkCodeToMessageCode(backendMessage.code),
            timestamp: backendMessage.timestamp,
            serviceData: ServiceData.none,
          ),
        );
      } else {
        await _handleAsyncEvent(
          Message(
            event: backendMessage.event,
            data: _chunksPartials[transactionCode],
            code: '',
            timestamp: backendMessage.timestamp,
            serviceData: ServiceData.none,
          ),
        );
      }
      _chunksPartials.remove(transactionCode);
    } else if (serviceData == ServiceData.transactionAbort) {
      _chunksPartials.remove(transactionCode);
    }
  }

  void _handleListeners<Event>(Event event) {
    if (_eventsSubscriptions[event]?.isNotEmpty != true && _eventsSubscriptions[event.runtimeType]?.isNotEmpty != true) {
      return;
    }
    final List<FrontendEventSubscription> subscriptions = [
      ..._eventsSubscriptions[event] ?? <FrontendEventSubscription>[],
      ..._eventsSubscriptions[event.runtimeType] ?? <FrontendEventSubscription>[],
    ];
    final List<FrontendEventSubscription> subscriptionsForDelete = [];
    for (final FrontendEventSubscription<dynamic> subscription in subscriptions) {
      if (subscription.isClosed) {
        subscriptionsForDelete.add(subscription);
        continue;
      }
      subscription.run(event);
    }
    for (final FrontendEventSubscription<dynamic> subscription in subscriptionsForDelete) {
      _eventsSubscriptions[event]?.removeWhere((FrontendEventSubscription me) => me == subscription);
      _eventsSubscriptions[event.runtimeType]?.removeWhere((FrontendEventSubscription me) => me == subscription);
    }
    subscriptionsForDelete.clear();
  }

  void _trackTime(String code, Message<dynamic, dynamic> message) {
    if (_timeTrackers.containsKey(code)) {
      final int diff = message.timestamp.microsecondsSinceEpoch - _timeTrackers[code]!.microsecondsSinceEpoch;
      print('Action ${message.code} took ${diff / 1000}ms');
      _timeTrackers.remove(code);
    }
  }

  late final Out _backendOut;
  late final In _frontendIn;
  late Type _backendType;
  late int _poolId;
  final Map<dynamic, Function> _actions = <dynamic, Function>{};
  final Map<String, Completer<dynamic>> _completers = {};
  final Map<String, DateTime> _timeTrackers = {};
  final Map<String, String> _runningFunctions = {};
  final Map<String, List<dynamic>> _chunksPartials = {};
  final Map<dynamic, Set<FrontendEventSubscription>> _eventsSubscriptions = <dynamic, Set<FrontendEventSubscription>>{};
}
