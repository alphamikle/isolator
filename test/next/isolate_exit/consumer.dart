import 'dart:isolate';

import '../template/mock_data.dart';

Future<void> main() async {
  await getValuesFromIsolate();
}

Future<List<MockData>> getValuesFromIsolate() async {
  final ReceivePort receivePort = ReceivePort();
  await Isolate.spawn(isolateHandler, receivePort.sendPort);
  return await receivePort.first as List<MockData>;
}

void isolateHandler(SendPort port) {
  const int items = 500000;
  final List<MockData> data = [];
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
  Isolate.exit(port, data);
}
