import 'package:isolator/next/backend/action_response.dart';
import 'package:isolator/next/backend/backend.dart';
import 'package:isolator/next/backend/backend_argument.dart';
import 'package:isolator/next/backend/chunks.dart';
import 'package:isolator/next/maybe.dart';

import '../template/mock_data.dart';
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

  Future<ActionResponse<MockData>> _getChunksFromSecondBackend({required FirstEvent event, required int data}) async {
    final Maybe<MockData> response = await secondBackInteractor.getChunks(data);
    return ActionResponse.chunks(Chunks(data: response.list));
  }

  @override
  void initActions() {
    whenEventCome(FirstEvent.computeInt).run(_getIntFromSecondBackend);
    whenEventCome(FirstEvent.computeChunks).run(_getChunksFromSecondBackend);
  }
}
