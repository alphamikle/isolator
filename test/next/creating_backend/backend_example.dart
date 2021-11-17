import 'package:isolator/next/backend/action_response.dart';
import 'package:isolator/next/backend/backend.dart';
import 'package:isolator/next/backend/backend_argument.dart';
import 'package:isolator/next/backend/chunks.dart';
import 'package:isolator/src/benchmark.dart';

import 'example_events.dart';
import 'mock_data.dart';

const int CHUNKS_SIZE = 500000;

class BackendExample extends Backend {
  BackendExample({required BackendArgument argument}) : super(argument: argument);

  ActionResponse<void> _notifyAboutMarkI({required ExampleEventMarkI event, void data}) {
    send(event: const ExampleEventMarkII(value: 12), data: ActionResponse.value(true));
    return ActionResponse.empty();
  }

  ActionResponse<dynamic> _handleMarkIIEvents({required ExampleEventMarkII event, void data}) {
    if (event.value == 1) {
      return ActionResponse<int>.value(2);
    }
    print('Got message Mark II with any value (${event.value}) in Backend');
    return ActionResponse<void>.empty();
  }

  Future<ActionResponse<void>> _returnBackLargeAmountOfDataViaChunks({required ChunksEvents event, void data}) async {
    bench.start('Send mocks');
    await send(
      event: ChunksEvents.eventFromBackendToFrontend,
      data: ActionResponse.chunks(Chunks(data: _generateData())),
    );
    bench.end('Send mocks');
    return ActionResponse.empty();
  }

  Future<ActionResponse<MockData>> _returnLargeDataSync({required ChunksEvents event, void data}) async {
    return ActionResponse.chunks(Chunks(data: _generateData(), size: 500, delay: const Duration(milliseconds: 1)));
  }

  List<MockData> _generateData() {
    final List<MockData> flatMocks = [];
    final List<MockData> deepMocks = [];
    bench.start('Generate mocks');
    for (int i = 0; i < CHUNKS_SIZE + 1; i++) {
      flatMocks.add(
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
    for (int i = 0; i < CHUNKS_SIZE; i++) {
      deepMocks.add(
        MockData(
          field1: i.toString(),
          field2: i.toString(),
          field3: i.toString(),
          field4: i.toString(),
          field5: i,
          field6: i,
          field7: i,
          field8: i,
          field9: flatMocks[i],
          field10: flatMocks[i + 1],
        ),
      );
    }
    bench.end('Generate mocks');
    return [...flatMocks, ...deepMocks];
  }

  @override
  void initActions() {
    on<ExampleEventMarkI>().run(_notifyAboutMarkI);
    on<ExampleEventMarkII>().run<void, dynamic>(_handleMarkIIEvents);
    on(ChunksEvents.eventFromFrontendToBackend).run(_returnBackLargeAmountOfDataViaChunks);
    on(ChunksEvents.eventFromFrontendToBackendSync).run(_returnLargeDataSync);
  }
}
