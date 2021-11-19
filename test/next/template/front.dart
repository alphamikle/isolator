import 'package:isolator/next/backend/backend_argument.dart';
import 'package:isolator/next/frontend/frontend.dart';

import 'back.dart';

class Front with Frontend {
  Future<void> init() async {
    await initBackend(initializer: createBack, backendType: Back);
  }

  @override
  void initActions() {
    // TODO: implement initActions
  }
}

void createBack(BackendArgument<void> argument) {
  Back(argument: argument);
}
