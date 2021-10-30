import 'package:example/states/first/first_backend.dart';
import 'package:example/states/second/second_backend.dart';
import 'package:isolator/isolator.dart';

class SecondBackendInteractor extends InteractorOf {
  SecondBackendInteractor(Backend backend) : super(backend);

  void sendIncrementEvent(int value) {
    sendMessage(SecondBackend, MessageBus.increment, value);
  }
}
