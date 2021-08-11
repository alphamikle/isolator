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
  Future<void> busMessageHandler(String isolateId, dynamic messageId, Packet3<Type, Type, dynamic> value, String? code) async {
    final _Message<dynamic, dynamic> message = _Message<dynamic, dynamic>(messageId, value: value, code: code);
    if (isolateId == Isolator.generateBackendId(Broadcast)) {
      for (final String backendId in sendPortsOfIsolates.keys) {
        final SendPort backendSendPort = sendPortsOfIsolates[backendId]!;
        final String senderId = Isolator.generateBackendId(value.value);
        if (backendId != senderId) {
          backendSendPort.send(message);
        }
      }
    } else {
      if (sendPortsOfIsolates.containsKey(isolateId)) {
        sendPortsOfIsolates[isolateId]!.send(message);
      } else {
        print('Not found Backend for id $isolateId');
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
