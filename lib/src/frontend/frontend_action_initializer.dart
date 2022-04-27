part of 'frontend.dart';

/// Class
class FrontendActionInitializer<Event> {
  /// Helper class, which you should now seen
  FrontendActionInitializer({
    required Frontend frontend,
    required Event? event,
    required Type? eventType,
  })  : assert(event != null || eventType != null && '$eventType' != 'dynamic'),
        _frontend = frontend,
        _event = event,
        _eventType = eventType;

  final Frontend _frontend;
  final Event? _event;
  final Type? _eventType;

  /// This method of this class you will use, when you will register
  /// Frontend handlers (methods)
  void run<Request, Response>(
    FrontendAction<Event, Request, Response> frontendAction,
  ) {
    if (_event != null) {
      _frontend._actions[_event!] = frontendAction;
    } else {
      _checkEventRegistration(_eventType!);
      _frontend._actions[_eventType!] = frontendAction;
    }
  }

  /// This method finishes registration of Backend's simple actions
  /// with data-argument
  void runSimple<Request, Response>(
      SimpleFrontendAction<Request, Response> frontendAction) {
    final finalizedAction = ({required Event event, required Request data}) {
      return frontendAction(data);
    };
    run(finalizedAction);
  }

  /// This method finishes registration of Backend's simple actions without
  /// data-argument
  void runVoid<Response>(VoidFrontendAction<Response> frontendAction) {
    final finalizedAction = ({required Event event, void data}) {
      return frontendAction();
    };
    run(finalizedAction);
  }

  void _checkEventRegistration(Type eventType) {
    for (final dynamic actionKey in _frontend._actions.keys) {
      final keyType = actionKey.runtimeType.toString();
      if (keyType == '$Type') {
        continue;
      }
      if (eventType.toString() == keyType) {
        throw Exception(
          initializerErrorText(actionKey: actionKey, eventType: eventType),
        );
      }
    }
  }
}
