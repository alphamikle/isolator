import 'dart:convert';
import 'dart:isolate';

import 'package:isolator/next/backend/action_response.dart';
import 'package:isolator/next/backend/backend.dart';
import 'package:isolator/next/backend/backend_argument.dart';
import 'package:isolator/src/benchmark.dart';

import 'event.dart';

class Back extends Backend {
  Back({
    required BackendArgument<void> argument,
  }) : super(argument: argument);

  ActionResponse<TransferableTypedData> _returnBigData({required Event event, void data}) {
    final StringBuffer buffer = StringBuffer();

    bench.start('GENERATE STRING');
    for (int i = 0; i < 1000 * 1000; i++) {
      buffer.write(i * i);
    }
    bench.end('GENERATE STRING');

    bench.start('TO TTD');
    final TransferableTypedData ttd = TransferableTypedData.fromList([utf8.encoder.convert(buffer.toString())]);
    bench.end('TO TTD');

    return ActionResponse.value(ttd);
  }

  ActionResponse<TransferableTypedData> _returnBigDataAsList({required Event event, void data}) {
    final StringBuffer buffer = StringBuffer();
    final List<TransferableTypedData> ttds = [];

    bench.start('GENERATE STRING');
    for (int i = 0; i < 1000 * 1000; i++) {
      buffer.write(i * i);
      if (i % 100 == 0) {
        ttds.add(TransferableTypedData.fromList([utf8.encoder.convert(buffer.toString())]));
        buffer.clear();
      }
    }
    bench.end('GENERATE STRING');

    return ActionResponse.list(ttds);
  }

  @override
  void initActions() {
    whenEventCome(Event.bigData).run(_returnBigData);
    whenEventCome(Event.bigDataAsList).run(_returnBigDataAsList);
  }
}
