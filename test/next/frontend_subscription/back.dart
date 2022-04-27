import 'package:isolator/src/backend/backend.dart';
import 'package:isolator/src/backend/backend_argument.dart';

import 'event.dart';

class Back extends Backend {
  Back({
    required BackendArgument<void> argument,
  }) : super(argument: argument);

  void _sendInt({required Event event, void data}) {
    send(event: Event.computeInt, data: 42);
  }

  @override
  void initActions() {
    whenEventCome(Event.computeInt).run(_sendInt);
  }
}
