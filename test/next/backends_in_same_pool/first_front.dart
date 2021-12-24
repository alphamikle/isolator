import 'package:isolator/src/backend/backend_argument.dart';
import 'package:isolator/src/frontend/frontend.dart';
import 'package:isolator/src/maybe.dart';

import 'event.dart';
import 'first_back.dart';

class FirstFront with Frontend {
  Future<int> computeInt() async {
    final Maybe<int> response = await run(event: FirstEvent.computeInt);
    return response.value;
  }

  Future<int> computeIntFromSecondBackend() async {
    final Maybe<int> response = await run(event: FirstEvent.computeIntFronSecondBackend);
    return response.value;
  }

  Future<void> init() async {
    await initBackend(initializer: createBack, poolId: 0);
  }

  @override
  void initActions() {}
}

FirstBack createBack(BackendArgument<void> argument) {
  return FirstBack(argument: argument);
}
