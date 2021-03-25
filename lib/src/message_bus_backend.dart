part of 'isolator.dart';

class MessageBusBackend extends Backend<MessageBusEvent> {
  MessageBusBackend(BackendArgument<void> argument) : super(argument);

  final Map<String, SendPort> sendPortsOfIsolates = {};

  void addIsolateSendPort(Packet2<String, SendPort> packet) {
    sendPortsOfIsolates[packet.value] = packet.value2;
  }

  void removeIsolateSendPort(String isolateId) {
    if (sendPortsOfIsolates.containsKey(isolateId)) {
      sendPortsOfIsolates.remove(isolateId);
    }
  }

  @override
  Future<void> busMessageHandler(String isolateId, dynamic messageId, dynamic? value, String? code) async {
    final _Message<dynamic, dynamic?> message = _Message(messageId, value: value, code: code);
    if (isolateId == Isolator.generateBackendId(Broadcast)) {
      for (final SendPort sendPort in sendPortsOfIsolates.values) {
        sendPort.send(message);
      }
    } else {
      if (sendPortsOfIsolates.containsKey(isolateId)) {
        print('START TO SEND MESSAGE TO BACKEND WITH ID = $isolateId / $messageId');
        sendPortsOfIsolates[isolateId]!.send(message);
      }
    }
  }

  @override
  Map<MessageBusEvent, Function> get operations {
    return {
      MessageBusEvent.addIsolateSendPort: addIsolateSendPort,
      MessageBusEvent.removeIsolateSendPort: removeIsolateSendPort,
    };
  }
}
