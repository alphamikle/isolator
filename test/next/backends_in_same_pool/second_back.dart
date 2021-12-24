import 'package:isolator/src/backend/action_response.dart';
import 'package:isolator/src/backend/backend.dart';
import 'package:isolator/src/backend/backend_argument.dart';

import 'event.dart';

class SecondBack extends Backend {
  SecondBack({
    required BackendArgument<void> argument,
  }) : super(argument: argument);

  ActionResponse<int> _computeInt({required SecondEvent event, void data}) {
    return ActionResponse.value(42);
  }

  @override
  void initActions() {
    whenEventCome(SecondEvent.computeInt).run(_computeInt);
  }
}