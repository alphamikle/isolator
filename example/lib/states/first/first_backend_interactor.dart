import 'package:example/states/first/first_backend.dart';
import 'package:isolator/isolator.dart';

class FirstBackendInteractor extends BackendInteractor {
  FirstBackendInteractor(Backend backend) : super(backend);

  void sendIncrementEvent(int value) {
    sendToAnotherBackend(FirstBackend, MessageBus.increment, value);
  }
}
