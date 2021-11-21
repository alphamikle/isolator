import 'package:isolator/next/backend/backend_argument.dart';
import 'package:isolator/next/frontend/frontend.dart';
import 'package:isolator/next/maybe.dart';

import '../template/mock_data.dart';
import 'event.dart';
import 'first_back.dart';

class FirstFront with Frontend {
  Future<int> computeInt() async {
    final Maybe<int> response = await run(event: FirstEvent.computeInt);
    return response.value;
  }

  Future<List<MockData>> computeChunks(int howMuch) async {
    final Maybe<MockData> response = await run(event: FirstEvent.computeChunks, data: howMuch);
    return response.list;
  }

  Future<void> init() async {
    await initBackend(initializer: createBack);
  }

  @override
  void initActions() {}
}

FirstBack createBack(BackendArgument<void> argument) {
  return FirstBack(argument: argument);
}
