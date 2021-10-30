import 'package:example/states/first/first_backend.dart';
import 'package:isolator/isolator.dart';

class FirstBackendInteractor extends InteractorOf {
  FirstBackendInteractor(Backend backend) : super(backend);

  void sendIncrementEvent(int value) {
    sendMessage(FirstBackend, MessageBus.increment, value);
  }
}
