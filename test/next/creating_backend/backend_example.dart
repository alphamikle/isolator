import 'package:isolator/next/backend/backend.dart';
import 'package:isolator/next/backend/backend_argument.dart';
import 'package:isolator/next/backend/void.dart';

import 'example_events.dart';

class BackendExample extends Backend {
  BackendExample({required BackendArgument argument}) : super(argument: argument);

  Void _notifyAboutMarkI({required ExampleEventMarkI event, void data}) {
    send(event: const ExampleEventMarkII(value: 12), data: true);
    return Void();
  }

  dynamic _handleMarkIIEvents({required ExampleEventMarkII event, void data}) {
    if (event.value == 1) {
      return 2;
    }
    print('Got message Mark II with any value (${event.value}) in Backend');
  }

  @override
  void initActions() {
    on<ExampleEventMarkI>().run(_notifyAboutMarkI);
    on<ExampleEventMarkII>().run<void, dynamic>(_handleMarkIIEvents);
  }
}
