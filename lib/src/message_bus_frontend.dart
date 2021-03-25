part of 'isolator.dart';

const String _MESSAGE_BUS = 'MESSAGE_BUS';

enum MessageBusEvent {
  addIsolateSendPort,
  removeIsolateSendPort,
}

class MessageBusFrontend with Frontend<MessageBusEvent> {
  void addIsolateSendPort(Packet2<String, SendPort> packet) {
    send(MessageBusEvent.addIsolateSendPort, packet);
  }

  void removeIsolateSendPort(String isolateId) {
    send(MessageBusEvent.removeIsolateSendPort, isolateId);
  }

  SendPort getMessageBusSendPort() {
    return backendSendPort;
  }

  Future<void> init() async {
    await initBackend(_createMessageBusBackend, uniqueId: _MESSAGE_BUS, isMessageBus: true, backendType: MessageBusBackend);
  }

  @override
  Map<MessageBusEvent, Function> get tasks {
    return {};
  }
}

void _createMessageBusBackend(BackendArgument<void> argument) {
  MessageBusBackend(argument);
}
