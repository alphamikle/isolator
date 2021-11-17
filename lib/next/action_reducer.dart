Function getAction(dynamic event, Map<dynamic, Function> actions, String debugName) {
  Function? action = actions[event];
  if (action == null) {
    for (final MapEntry<dynamic, Function> entry in actions.entries) {
      if (event.runtimeType.toString() == '$Type') {
        throw Exception('[$debugName] You need to register action for type $event');
      }
      if (event.runtimeType.toString() == entry.key.toString()) {
        action = entry.value;
        break;
      }
    }
  }
  if (action == null) {
    throw Exception('[$debugName] Not found action for event $event or event type ${event.runtimeType}');
  }
  return action;
}
