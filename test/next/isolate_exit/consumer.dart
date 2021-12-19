import 'dart:isolate';

import 'package:isolator/next/backend/action_response.dart';
import 'package:isolator/src/benchmark.dart';

import '../template/mock_data.dart';

Future<void> main() async {
  await getValuesFromIsolate();
}

Future<void> getValuesFromIsolate() async {
  final ReceivePort receivePort = ReceivePort();
  bench.start('--> 0');
  await Isolate.spawn(isolateHandler, receivePort.sendPort);
  bench.end('--> 0');

  bench.start('--> 1');
  final int now = DateTime.now().microsecondsSinceEpoch;
  final ActionResponse<MockData> data = await receivePort.first as ActionResponse<MockData>;
  print('--> 2: ${(data.timestamp.microsecondsSinceEpoch - now) / 1000}ms');
  bench.end('--> 1');
}

void isolateHandler(SendPort port) {
  const int items = 500000;
  final List<MockData> data = [];

  bench.start('--> 3');
  for (int i = 0; i < items; i++) {
    data.add(
      MockData(
        field1: i.toString(),
        field2: i.toString(),
        field3: i.toString(),
        field4: i.toString(),
        field5: i,
        field6: i,
        field7: i,
        field8: i,
        field9: null,
        field10: null,
      ),
    );
  }
  bench.end('--> 3');
  if (false) {
    port.send(ActionResponse.list(data));
    Isolate.current.kill();
  } else {
    Isolate.exit(port, ActionResponse.list(data));
  }
}
