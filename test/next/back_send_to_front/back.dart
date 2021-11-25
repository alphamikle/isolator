import 'package:isolator/next/backend/action_response.dart';
import 'package:isolator/next/backend/backend.dart';
import 'package:isolator/next/backend/backend_argument.dart';

import 'event.dart';

class Back extends Backend {
  Back({
    required BackendArgument<void> argument,
  }) : super(argument: argument);

  ActionResponse<void> _sendValue({required Event event, void data}) {
    send(event: Event.getMessageWithValue, data: ActionResponse.value(42));
    return ActionResponse.empty();
  }

  ActionResponse<void> _sendList({required Event event, void data}) {
    send(event: Event.getMessageWithList, data: ActionResponse.value([1, 2, 3, 4, 5]), forceUpdate: true);
    return ActionResponse.empty();
  }

  ActionResponse<void> _sendChunks({required Event event, void data}) {
    send(event: Event.getMessageWithChunks, data: ActionResponse.value(List.filled(100, 1)));
    return ActionResponse.empty();
  }

  Future<ActionResponse<void>> _sendSeveralMessages({required Event event, void data}) async {
    await send(event: Event.getMessageWithValue, data: ActionResponse.value(42));
    await send(event: Event.getMessageWithList, data: ActionResponse.value([1, 2, 3, 4, 5]));
    await send(event: Event.getMessageWithChunks, data: ActionResponse.value(List.filled(100, 1)), forceUpdate: true);
    return ActionResponse.empty();
  }

  @override
  void initActions() {
    when(Event.getMessageWithValue).run(_sendValue);
    when(Event.getMessageWithList).run(_sendList);
    when(Event.getMessageWithChunks).run(_sendChunks);
    when(Event.getSeveralMessages).run(_sendSeveralMessages);
  }
}
