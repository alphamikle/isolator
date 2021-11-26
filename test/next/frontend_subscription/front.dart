import 'package:isolator/next/backend/backend_argument.dart';
import 'package:isolator/next/frontend/frontend.dart';

import 'back.dart';
import 'event.dart';

class Front with Frontend {
  int value = 0;

  void sendEventAboutInt() => run(event: Event.computeInt);

  void _setInt({required Event event, required int data}) {
    value = data;
  }

  Future<void> init() async {
    await initBackend(initializer: createBack);
  }

  @override
  void initActions() {
    whenEventCome(Event.computeInt).run(_setInt);
  }
}

Back createBack(BackendArgument<void> argument) {
  return Back(argument: argument);
}
