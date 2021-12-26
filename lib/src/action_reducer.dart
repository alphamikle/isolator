library isolator;

/// Inner layer helper for the Transporter
Function getAction(
  dynamic event,
  Map<dynamic, Function> actions,
  String debugName,
) {
  final eventRuntimeType = event.runtimeType.toString();
  var action = actions[event];
  if (action == null) {
    for (final entry in actions.entries) {
      if (eventRuntimeType == '$Type') {
        throw Exception(
            '[$debugName] You need to register action for type $event');
      }
      if (eventRuntimeType == entry.key.toString()) {
        action = entry.value;
        break;
      }
    }
  }
  if (action == null) {
    throw Exception(
      '''[$debugName] Not found action for event $event or event type ${event.runtimeType}''',
    );
  }
  return action;
}
