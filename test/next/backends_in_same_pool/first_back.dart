import 'package:isolator/next/backend/action_response.dart';
import 'package:isolator/next/backend/backend.dart';
import 'package:isolator/next/backend/backend_argument.dart';
import 'package:isolator/next/maybe.dart';

import 'event.dart';
import 'second_back_interactor.dart';

class FirstBack extends Backend {
  FirstBack({
    required BackendArgument<void> argument,
  }) : super(argument: argument);

  late final SecondBackInteractor secondBackInteractor = SecondBackInteractor(this);

  Future<ActionResponse<int>> _getInt({required FirstEvent event, void data}) async {
    return ActionResponse.value(42);
  }

  Future<ActionResponse<int>> _getIntFromSecondBack({required FirstEvent event, void data}) async {
    final Maybe<int> response = await secondBackInteractor.getInt();
    return ActionResponse.value(response.value);
  }

  @override
  void initActions() {
    when(FirstEvent.computeInt).run(_getInt);
    when(FirstEvent.computeIntFronSecondBackend).run(_getIntFromSecondBack);
  }
}
