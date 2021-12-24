import 'package:isolator/src/backend/backend.dart';
import 'package:isolator/src/maybe.dart';

import 'event.dart';
import 'second_back.dart';

class SecondBackInteractor extends InteractorOf<SecondBack> {
  SecondBackInteractor(Backend backend) : super(backend);

  Future<Maybe<int>> getInt() async {
    return run(event: SecondEvent.computeInt);
  }
}
