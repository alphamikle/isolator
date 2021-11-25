import 'package:isolator/next/backend/action_response.dart';
import 'package:isolator/next/backend/backend.dart';
import 'package:isolator/next/backend/backend_argument.dart';

import '../template/mock_data.dart';
import 'event.dart';

class SecondBack extends Backend {
  SecondBack({
    required BackendArgument<void> argument,
  }) : super(argument: argument);

  ActionResponse<int> _computeInt({required SecondEvent event, void data}) {
    return ActionResponse.value(42);
  }

  ActionResponse<MockData> _computeChunks({required SecondEvent event, required int data}) {
    return ActionResponse.list([
      for (int i = 0; i < data; i++)
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
        )
    ]);
  }

  @override
  void initActions() {
    when(SecondEvent.computeInt).run(_computeInt);
    when(SecondEvent.computeChunks).run(_computeChunks);
  }
}
