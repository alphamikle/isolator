import 'package:isolator/src/backend/backend_argument.dart';
import 'package:isolator/src/frontend/frontend.dart';
import 'package:isolator/src/maybe.dart';

import '../template/mock_data.dart';
import 'back.dart';
import 'event.dart';

class Front with Frontend {
  Future<void> doNothing() async {
    await run(event: Event.doNothing);
  }

  Future<int> computeInt() async {
    final Maybe<int> response = await run(event: Event.computeInt);
    return response.value;
  }

  Future<Maybe<int>> throwError() async {
    final Maybe<int> response = await run(event: Event.throwError);
    return response;
  }

  Future<List<MockData>> computeList() async {
    final Maybe<List<MockData>> response = await run(event: Event.computeList);
    return response.value;
  }

  Future<List<MockData>> computeListAsValue() async {
    final Maybe<List<MockData>> response = await run(event: Event.computeListAsValue);
    print(response.runtimeType);
    return response.value;
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
