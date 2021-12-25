import 'dart:async';

import 'package:isolator/src/backend/backend.dart';
import 'package:isolator/src/backend/backend_argument.dart';
import 'package:isolator/src/backend/backend_create_result.dart';
import 'package:isolator/src/backend/backend_init_result.dart';
import 'package:isolator/src/data_bus/data_bus.dart';
import 'package:isolator/src/data_bus/data_bus_backend_init_message.dart';
import 'package:isolator/src/data_bus/data_bus_init_result.dart';
import 'package:isolator/src/in/in_abstract.dart';
import 'package:isolator/src/isolator/isolator_abstract.dart';
import 'package:isolator/src/out/out_abstract.dart';
import 'package:isolator/src/types.dart';

/// Class
class IsolatorWeb implements Isolator {
  /// Isolator for web
  factory IsolatorWeb() => _instance ??= IsolatorWeb._();

  IsolatorWeb._();

  final Map<int, List<Backend>> _backends = {};
  // late final DataBus _dataBus;
  static late final In _fromBackendsToDataBusIn;
  static bool _isDataBusCreating = false;
  static bool _isDataBusCreated = false;
  static IsolatorWeb? _instance;

  @override
  Future<BackendCreateResult> isolate<T, B extends Backend>({
    required BackendInitializer<T, B> initializer,
    IsolatePoolId? poolId,
    T? data,
  }) async {
    if (!_isDataBusCreated) {
      await _createDataBus();
    }
    final pid = poolId ?? 0;
    if (_backends[pid] == null) {
      _backends[pid] = [];
    }
    final backendOut = Out.create<dynamic>();
    late final In frontendToBackendIn;
    final backendInitializerCompleter = Completer<void>();
    void listener(dynamic data) {
      if (data is BackendInitResult) {
        frontendToBackendIn = data.frontendToBackendIn;
        _fromBackendsToDataBusIn.send(
          DataBusBackendInitMessage(
            backendIn: data.dataBusToBackendIn,
            backendId: _generateBackendIdFromType(B),
            type: MessageType.add,
          ),
        );
        backendInitializerCompleter.complete();
      } else {
        throw Exception(
          'Got incorrect message from Backend in Isolate initializer',
        );
      }
    }

    final subscription = backendOut.listen(listener);
    final Backend backend = initializer(
      BackendArgument(
        toFrontendIn: backendOut.createIn,
        toDataBusIn: _fromBackendsToDataBusIn,
        data: data,
      ),
    );
    _backends[pid]!.add(backend);
    await backendInitializerCompleter.future;
    await subscription.cancel();
    print('"$B" was created in pool $pid');
    return BackendCreateResult(
      backendOut: backendOut,
      frontendIn: frontendToBackendIn,
      poolId: pid,
    );
  }

  @override
  Future<void> close({
    required Type backendType,
    required int poolId,
  }) async {
    _backends[poolId]?.removeWhere(
      (Backend me) => me.runtimeType == backendType,
    );
  }

  Future<void> _createDataBus() async {
    if (_isDataBusCreating) {
      while (_isDataBusCreating) {
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }
      return;
    }
    _isDataBusCreating = true;
    final dataBusInitializerCompleter = Completer<void>();
    final tempDataBusOut = Out.create<dynamic>();

    void listener(dynamic data) {
      if (data is DataBusInitResult) {
        _fromBackendsToDataBusIn = data.backendToDataBusIn;
        dataBusInitializerCompleter.complete();
      } else {
        throw Exception(
          'Got incorrect message from DataBus in Isolate initializer',
        );
      }
    }

    tempDataBusOut.listen(listener);
    /*_dataBus = */ createDataBus(tempDataBusOut.createIn);
    await dataBusInitializerCompleter.future;
    _isDataBusCreating = false;
    _isDataBusCreated = true;
  }

  String _generateBackendIdFromType(Type backendType) => '$backendType';
}

/// Inner package factory
Isolator createIsolator() => IsolatorWeb();
