import 'package:isolator/next/backend/action_response.dart';
import 'package:isolator/next/backend/backend.dart';
import 'package:isolator/next/backend/backend_argument.dart';

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
    on(SecondEvent.computeInt).run(_computeInt);
  }
}
