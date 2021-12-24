import 'package:isolator/src/backend/backend.dart';
import 'package:isolator/src/maybe.dart';

import '../template/mock_data.dart';
import 'event.dart';
import 'second_back.dart';

class SecondBackInteractor extends InteractorOf<SecondBack> {
  SecondBackInteractor(Backend backend) : super(backend);

  Future<Maybe<int>> getInt() async {
    return run(event: SecondEvent.computeInt);
  }

  Future<Maybe<MockData>> getChunks(int howMuch) async {
    return run(event: SecondEvent.computeChunks, data: howMuch);
  }
}
