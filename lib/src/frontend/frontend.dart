library isolator;

import 'dart:async';
import 'dart:developer';

import 'package:isolator/src/action_reducer.dart';
import 'package:isolator/src/backend/backend.dart';
import 'package:isolator/src/backend/initializer_error_text.dart';
import 'package:isolator/src/frontend/frontend_event_subscription.dart';
import 'package:isolator/src/in/in_abstract.dart';
import 'package:isolator/src/isolator/isolator_abstract.dart';
import 'package:isolator/src/maybe.dart';
import 'package:isolator/src/message.dart';
import 'package:isolator/src/out/out_abstract.dart';
import 'package:isolator/src/tools/helpers.dart';
import 'package:isolator/src/types.dart';
import 'package:meta/meta.dart';

part 'frontend_action_initializer.dart';
part 'frontend_action_subscriber.dart';

/// This is the first part of two-class component. Frontend will run in the
/// UI-thread and its purpose is to update the UI after getting messages from
/// the [Backend] or after calling [Backend]'s methods
mixin Frontend {
  /// Method in which you should register all your [Frontend] handlers
  /// (methods, which will call on [Backend]'s messages)
  @protected
  void initActions();

  /// This hook will called if [Backend.send] method
  /// will use [forceUpdate: true] param
  @protected
  void onForceUpdate() {}

  /// This hook will be called on every message from the [Backend]
  @protected
  void onEveryEvent() {}

  /// You can change this getter to update the UI automatically
  /// after getting every event from the [Backend]
  @protected
  bool get updateOnEveryEvent => false;

  /// Method for calling the [Backend]'s registered actions from the [Frontend]
  @protected
  Future<Maybe<Res>> run<Event, Req extends Object?, Res extends Object?>({
    required Event event,
    Req? data,
    Duration? timeout,
    bool trackTime = false,
  }) async {
    final code = generateMessageCode(event);
    final completer = Completer<Maybe<dynamic>>();
    final currentTrace = StackTrace.current;
    final runningFunctionName = getNameOfParentRunningFunction(
      currentTrace.toString(),
    );
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
        throw Exception(
            'Timeout ($timeout) of action $event with code $code exceed');
      });
    }
    final result = await completer.future;
    timer?.cancel();
    _completers.remove(code);
    _runningFunctions.remove(code);
    return result.castTo<Res>();
  }

  /// The same thing as in the [Backend] - this method using to register
  /// [Frontend] handlers (in [initActions] method)
  @protected
  FrontendActionInitializer<Event> whenEventCome<Event>([Event? event]) =>
      FrontendActionInitializer(
        frontend: this,
        event: event,
        eventType: Event,
      );

  /// With this method you can subscribe on every [Frontend] to getting
  /// notifications about new events in this [Frontend]
  FrontendEventSubscription<Event> subscribeOnEvent<Event>({
    required FrontendEventListener<Event> listener,

    /// Will called only once and automatically closed
    bool single = false,

    /// If true - this listener will been called on every action with this event
    /// If false - only on forceUpdate (if these events will be)
    bool onEveryEvent = false,

    /// The event, on that you will subscribe
    Event? event,
  }) {
    return FrontendActionSubscriber(
      frontend: this,
      event: event,
      eventType: Event,
    ).subscribe(
      single: single,
      listener: listener,
      onEveryEvent: onEveryEvent,
    );
  }

  /// This inner method was created to initialize corresponding [Backend]
  @mustCallSuper
  Future<void> initBackend<T, B extends Backend>({
    required BackendInitializer<T, B> initializer,
    IsolatePoolId? poolId,
    T? data,
  }) async {
    initActions();
    final result = await Isolator.instance.isolate(
      initializer: initializer,
      poolId: poolId,
    );
    _backendType = B;
    _poolId = result.poolId;
    _backendOut = result.backendOut;
    _frontendIn = result.frontendIn;
    _backendOut.listen(_backendMessageRawHandler);
  }

  /// Like "dispose()" in different classes
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

  Future<void> _backendMessageHandler<Event, Data>(
      Message<Event, Data> backendMessage) async {
    if (backendMessage.code.isNotEmpty) {
      await _handleSyncEvent<Event, Data>(backendMessage);
    } else {
      await _handleAsyncEvent<Event, Data>(backendMessage);
    }
    _handleListeners(backendMessage.event);
  }

  Future<void> _handleSyncEvent<Event, Data>(
      Message<Event, Data> backendMessage) async {
    final code = backendMessage.code;
    try {
      if (!_completers.containsKey(code)) {
        throw Exception('''
[isolator]
Not found Completer for event ${backendMessage.event} with code $code.
Maybe you`ve seen Timeout exception?
''');
      }
      final data = backendMessage.data;
      (_completers[code]! as Completer<Data>).complete(data);
      onEveryEvent();
      if (backendMessage.forceUpdate || updateOnEveryEvent) {
        onForceUpdate();
      }
    } catch (error) {
      log('''
[isolator]
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

  Future<void> _handleAsyncEvent<Event, Data>(
      Message<Event, Data> backendMessage) async {
    late Function action;
    try {
      action = getAction(
        backendMessage.event,
        _actions,
        runtimeType.toString(),
      );
      action(event: backendMessage.event, data: backendMessage.data);
      onEveryEvent();
      if (backendMessage.forceUpdate || updateOnEveryEvent) {
        onForceUpdate();
      }
    } catch (error) {
      log('''
[isolator]
[$runtimeType] Async action error
Data: ${objectToTypedString(backendMessage.data)}
Event: ${objectToTypedString(backendMessage.event)}
Code: ${backendMessage.code}
Action: ${objectToTypedString(action)}
Additional info: ${_runningFunctions[backendMessage.code] ?? StackTrace.current}
Error: ${errorToString(error)}
Stacktrace: ${errorStackTraceToString(error)}
''');
      _runningFunctions.remove(backendMessage.code);
      rethrow;
    }
    _trackTime(backendMessage.code, backendMessage);
  }

  void _handleListeners<Event>(Event event) {
    if (_eventsSubscriptions[event]?.isNotEmpty != true &&
        _eventsSubscriptions[event.runtimeType]?.isNotEmpty != true) {
      return;
    }
    final subscriptions = [
      ..._eventsSubscriptions[event] ?? <FrontendEventSubscription>[],
      ..._eventsSubscriptions[event.runtimeType] ??
          <FrontendEventSubscription>[],
    ];
    final subscriptionsForDelete = <FrontendEventSubscription>[];
    for (final subscription in subscriptions) {
      if (subscription.isClosed) {
        subscriptionsForDelete.add(subscription);
        continue;
      }
      subscription.run(event);
    }
    for (final subscription in subscriptionsForDelete) {
      _eventsSubscriptions[event]?.removeWhere(
        (FrontendEventSubscription me) => me == subscription,
      );
      _eventsSubscriptions[event.runtimeType]?.removeWhere(
        (FrontendEventSubscription me) => me == subscription,
      );
    }
    subscriptionsForDelete.clear();
  }

  void _trackTime(String code, Message<dynamic, dynamic> message) {
    if (_timeTrackers.containsKey(code)) {
      final diff = message.timestamp.microsecondsSinceEpoch -
          _timeTrackers[code]!.microsecondsSinceEpoch;
      log('Action ${message.code} took ${diff / 1000}ms');
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
  final Map<dynamic, Set<FrontendEventSubscription>> _eventsSubscriptions =
      <dynamic, Set<FrontendEventSubscription>>{};
}
