import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:isolator/src/backend/backend_argument.dart';
import 'package:isolator/src/frontend/frontend.dart';
import 'package:isolator/src/maybe.dart';
import 'package:isolator/src/tools/benchmark.dart';

import 'back.dart';
import 'event.dart';

class Front with Frontend {
  Future<String> getBigData() async {
    final Maybe<TransferableTypedData> response = await run(event: Event.bigData, trackTime: true);

    bench.start('MATERIALIZE');
    final ByteBuffer buffer = response.value.materialize();
    bench.end('MATERIALIZE');

    bench.start('TO STRING');
    final String string = utf8.decoder.convert(buffer.asInt8List());
    bench.end('TO STRING');

    print(string.length);

    return string;
  }

  Future<String> getBigDataAsList() async {
    final Maybe<TransferableTypedData> response =
        await run(event: Event.bigDataAsList, trackTime: true);

    bench.start('MATERIALIZE');
    final List<ByteBuffer> buffers =
        response.list.map((TransferableTypedData me) => me.materialize()).toList();
    bench.end('MATERIALIZE');

    bench.start('TO STRING');
    final String string = buffers.map((me) => utf8.decoder.convert(me.asInt8List())).join();
    bench.end('TO STRING');

    print(string.length);

    return string;
  }

  Future<void> init() async {
    await initBackend(initializer: createBack);
  }

  @override
  void initActions() {}
}

Back createBack(BackendArgument<void> argument) {
  return Back(argument: argument);
}
