part of 'backend.dart';

/// Helper class to register Backend's actions
@immutable
class BackendActionInitializer<Event> {
  /// Helper class to register Backend's actions
  const BackendActionInitializer({
    required Backend backend,
    required Event? event,
    required Type? eventType,
  })  : assert(event != null || eventType != null && '$eventType' != 'dynamic'),
        _backend = backend,
        _event = event,
        _eventType = eventType;

  final Backend _backend;
  final Event? _event;
  final Type? _eventType;

  /// This method finishes registration of Backend's actions
  void run<Request, Response>(
    BackendAction<Event, Request, Response> backendAction,
  ) {
    if (_event != null) {
      _backend._actions[_event!] = backendAction;
    } else {
      _checkEventRegistration(_eventType!);
      _backend._actions[_eventType!] = backendAction;
    }
  }

  /// This method finishes registration of Backend's simple actions
  /// with data-argument
  void runSimple<Request, Response>(
      SimpleBackendAction<Request, Response> backendAction) {
    final finalizedAction = ({required Event event, required Request data}) {
      return backendAction(data);
    };
    run(finalizedAction);
  }

  /// This method finishes registration of Backend's simple actions without
  /// data-argument
  void runVoid<Response>(VoidBackendAction<Response> backendAction) {
    final finalizedAction = ({required Event event, void data}) {
      return backendAction();
    };
    run(finalizedAction);
  }

  void _checkEventRegistration(Type eventType) {
    for (final dynamic actionKey in _backend._actions.keys) {
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
