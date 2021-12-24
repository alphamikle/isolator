import 'package:isolator/src/backend/action_response.dart';
import 'package:isolator/src/backend/backend.dart';
import 'package:isolator/src/backend/backend_argument.dart';

import 'event.dart';

class Back extends Backend {
  Back({
    required BackendArgument<void> argument,
  }) : super(argument: argument);

  ActionResponse<void> _sendInt({required Event event, void data}) {
    send(event: Event.computeInt, data: 42);
    return ActionResponse.empty();
  }

  @override
  void initActions() {
    whenEventCome(Event.computeInt).run(_sendInt);
  }
}
