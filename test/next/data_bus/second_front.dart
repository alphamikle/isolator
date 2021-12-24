import 'package:isolator/src/backend/backend_argument.dart';
import 'package:isolator/src/frontend/frontend.dart';

import 'second_back.dart';

class SecondFront with Frontend {
  Future<void> init() async {
    await initBackend(initializer: createBack);
  }

  @override
  void initActions() {}
}

SecondBack createBack(BackendArgument<void> argument) {
  return SecondBack(argument: argument);
}
