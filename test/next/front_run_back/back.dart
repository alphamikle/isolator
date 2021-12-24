import 'package:isolator/src/backend/action_response.dart';
import 'package:isolator/src/backend/backend.dart';
import 'package:isolator/src/backend/backend_argument.dart';

import '../template/mock_data.dart';
import 'event.dart';

class Back extends Backend {
  Back({
    required BackendArgument<void> argument,
  }) : super(argument: argument);

  ActionResponse<void> _doNothing({required Event event, void data}) {
    return ActionResponse.empty();
  }

  ActionResponse<int> _computeInt({required Event event, void data}) {
    return ActionResponse.value(42);
  }

  ActionResponse<int> _throwError({required Event event, void data}) {
    throw Exception('Exception 42');
  }

  ActionResponse<MockData> _computeList({required Event event, void data}) {
    final List<MockData> chunks = [];
    for (int i = 0; i < 100; i++) {
      chunks.add(
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
    return ActionResponse.list(chunks);
  }

  @override
  void initActions() {
    whenEventCome(Event.doNothing).run(_doNothing);
    whenEventCome(Event.computeInt).run(_computeInt);
    whenEventCome(Event.throwError).run(_throwError);
    whenEventCome(Event.computeList).run(_computeList);
  }
}
