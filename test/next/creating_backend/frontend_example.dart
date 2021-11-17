import 'package:isolator/next/backend/backend_argument.dart';
import 'package:isolator/next/frontend/frontend.dart';
import 'package:isolator/next/maybe.dart';

import 'backend_example.dart';
import 'example_events.dart';

class FrontendExample with Frontend {
  bool isMessageReceived = false;

  Future<int> computeIntOnBackend() async {
    final Maybe value = await run(event: const ExampleEventMarkII(value: 1));
    return value.getData() ?? 0;
  }

  void runBackendEventWithSendingMessageBack() => run(event: ExampleEventMarkI());

  void _notifyAboutMarkII({required ExampleEventMarkII event, required bool data}) => isMessageReceived = data;

  Future<void> init() async => initBackend<void>(initializer: createExampleBackend, backendType: BackendExample);

  @override
  void initActions() {
    on<ExampleEventMarkII>().run(_notifyAboutMarkII);
  }
}

void createExampleBackend(BackendArgument argument) {
  BackendExample(argument: argument);
}
