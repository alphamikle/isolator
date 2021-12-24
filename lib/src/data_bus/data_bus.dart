import 'package:isolator/src/data_bus/data_bus_backend_init_message.dart';
import 'package:isolator/src/data_bus/data_bus_dto.dart';
import 'package:isolator/src/data_bus/data_bus_init_result.dart';
import 'package:isolator/src/in/in_abstract.dart';
import 'package:isolator/src/out/out_abstract.dart';
import 'package:isolator/src/types.dart';

class DataBus {
  DataBus({required In toFrontendTempIn})
      : _fromBackendsOut = Out.create<dynamic>(),
        _toFrontendTempIn = toFrontendTempIn {
    _fromBackendsOut.listen(_handleMessageFromBackend);
    _sendMineInBack();
  }

  In? _toFrontendTempIn;
  final Out _fromBackendsOut;
  final Map<BackendId, In> _toBackendsIns = {};

  void _handleMessageFromBackend(dynamic message) {
    if (message is DataBusBackendInitMessage && message.type == MessageType.add) {
      _addBackendMessage(message);
    } else if (message is DataBusBackendInitMessage && message.type == MessageType.remove) {
      _removeBackendMessage(message);
    } else if (message is DataBusDto) {
      _sendDto<dynamic, dynamic>(message);
    } else {
      throw UnimplementedError('_handleMessageFromBackend');
    }
  }

  void _addBackendMessage(DataBusBackendInitMessage message) {
    assert(message.backendIn != null);
    _toBackendsIns[message.backendId] = message.backendIn!;
  }

  void _removeBackendMessage(DataBusBackendInitMessage message) {
    _toBackendsIns.remove(message.backendId);
  }

  void _sendDto<Event, Data>(DataBusDto<Event> request) {
    final In? targetBackendIn = _toBackendsIns[request.to];
    if (targetBackendIn == null) {
      throw Exception('${request.to} not registered in DataBus');
    }
    targetBackendIn.send(request);
  }

  void _sendMineInBack() {
    _toFrontendTempIn!.send(DataBusInitResult(backendToDataBusIn: _fromBackendsOut.createIn));
    _toFrontendTempIn = null;
  }
}

DataBus createDataBus(In toFrontendTempIn) {
  return DataBus(toFrontendTempIn: toFrontendTempIn);
}