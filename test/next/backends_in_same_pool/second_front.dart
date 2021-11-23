import 'package:isolator/next/backend/backend_argument.dart';
import 'package:isolator/next/frontend/frontend.dart';
import 'package:isolator/next/maybe.dart';

import 'event.dart';
import 'second_back.dart';

class SecondFront with Frontend {
  Future<int> computeInt() async {
    final Maybe<int> response = await run(event: SecondEvent.computeInt);
    return response.value;
  }

  Future<void> init() async {
    await initBackend(initializer: createBack, poolId: 0);
  }

  @override
  void initActions() {}
}

SecondBack createBack(BackendArgument<void> argument) {
  return SecondBack(argument: argument);
}
