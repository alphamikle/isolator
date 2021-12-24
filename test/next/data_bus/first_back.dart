import 'package:isolator/src/backend/action_response.dart';
import 'package:isolator/src/backend/backend.dart';
import 'package:isolator/src/backend/backend_argument.dart';
import 'package:isolator/src/maybe.dart';

import 'event.dart';
import 'second_back_interactor.dart';

class FirstBack extends Backend {
  FirstBack({
    required BackendArgument<void> argument,
  }) : super(argument: argument);

  late final SecondBackInteractor secondBackInteractor = SecondBackInteractor(this);

  Future<ActionResponse<int>> _getIntFromSecondBackend({required FirstEvent event, void data}) async {
    final Maybe<int> response = await secondBackInteractor.getInt();
    return ActionResponse.value(response.value);
  }

  @override
  void initActions() {
    whenEventCome(FirstEvent.computeInt).run(_getIntFromSecondBackend);
  }
}
