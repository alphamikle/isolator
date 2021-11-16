import 'package:isolator/next/backend/backend_argument.dart';
import 'package:isolator/next/frontend/frontend.dart';
import 'package:isolator/next/maybe.dart';

import 'backend_example.dart';
import 'example_events.dart';

class FrontendExample with Frontend {
  void _notifyAboutMarkII({required ExampleEventMarkII event, required void data}) {
    print('Got message Mark II with any value (${event.value}) in Frontend');
  }

  @override
  void initActions() {
    on<ExampleEventMarkII>().run(_notifyAboutMarkII);
  }

  Future<int> computeIntOnBackend() async {
    final Maybe value = await run(event: const ExampleEventMarkII(value: 1));
    return value.getData() ?? 0;
  }

  Future<void> init() async => initBackend<void>(initializer: createExampleBackend, backendType: BackendExample);
}

void createExampleBackend(BackendArgument argument) {
  BackendExample(argument: argument);
}
