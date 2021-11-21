import 'dart:async';
import 'dart:collection';
import 'dart:isolate';

import 'package:isolator/next/backend/backend_argument.dart';
import 'package:isolator/next/backend/backend_create_result.dart';
import 'package:isolator/next/backend/backend_init_result.dart';
import 'package:isolator/next/data_bus/data_bus.dart';
import 'package:isolator/next/data_bus/data_bus_backend_init_message.dart';
import 'package:isolator/next/data_bus/data_bus_init_result.dart';
import 'package:isolator/next/in/in_abstract.dart';
import 'package:isolator/next/isolator/isolate_container.dart';
import 'package:isolator/next/isolator/isolator_abstract.dart';
import 'package:isolator/next/out/out_abstract.dart';
import 'package:isolator/next/out/out_native.dart';
import 'package:isolator/next/types.dart';

int _poolId = 0;
SplayTreeSet<int> _freedPoolIds = SplayTreeSet();

class IsolatorNative implements Isolator {
  factory IsolatorNative() => _instance ??= IsolatorNative._();
  IsolatorNative._();

  static IsolatorNative? _instance;
  static final Map<IsolatePoolId, IsolateContainer?> _isolates = {};
  static late final Isolate _dataBusIsolate;
  static late final In _fromBackendsToDataBusIn;
  static bool _isDataBusCreating = false;
  static bool _isDataBusCreated = false;

  @override
  Future<BackendCreateResult> isolate<T, B>({
    required BackendInitializer<T, B> initializer,
    IsolatePoolId? poolId,
    T? data,
  }) async {
    if (!_isDataBusCreated) {
      await _createDataBus();
    }
    late final int pid;
    if (poolId != null) {
      pid = poolId;
    } else if (_freedPoolIds.isNotEmpty) {
      final int firstFreePoolId = _freedPoolIds.first;
      pid = firstFreePoolId;
      _freedPoolIds.remove(firstFreePoolId);
    } else {
      pid = _poolId++;
    }
    if (_isPoolExist(pid)) {
      return _addBackendToExistIsolate();
    }
    return _createNewIsolate<T, B>(
      initializer: initializer,
      poolId: pid,
      data: data,
    );
  }

  @override
  Future<void> close({
    required Type backendType,
    required int poolId,
  }) async {
    if (!_isPoolExist(poolId)) {
      return;
    }
    final IsolateContainer container = _isolates[poolId]!;
    if (!container.isolatesIds.contains(_generateBackendIdFromType(backendType))) {
      return;
    }
    if (container.isolatesIds.length == 1) {
      await _closeContainerOfIsolates(poolId);
    } else {
      await _closeBackendFromPool(backendType: backendType, poolId: poolId);
    }
  }

  Future<BackendCreateResult> _createNewIsolate<T, B>({
    required BackendInitializer<T, B> initializer,
    required IsolatePoolId poolId,
    T? data,
  }) async {
    _isolates[poolId] = null;
    final Out<dynamic> backendOut = OutNative<dynamic>();
    late final In frontendToBackendIn;
    final Completer<void> backendInitializerCompleter = Completer();
    void listener(dynamic data) {
      if (data is BackendInitResult) {
        frontendToBackendIn = data.frontendToBackendIn;
        _fromBackendsToDataBusIn.send(
          DataBusBackendInitMessage(
            backendIn: data.dataBusToBackendIn,
            backendId: B.toString(),
            type: MessageType.add,
          ),
        );
        backendInitializerCompleter.complete();
      } else {
        throw Exception('Got incorrect message from Backend in Isolate initializer');
      }
    }

    final StreamSubscription<dynamic> subscription = backendOut.listen(listener);
    final Isolate isolate = await Isolate.spawn<BackendArgument<T>>(
      initializer,
      BackendArgument(
        toFrontendIn: backendOut.createIn,
        toDataBusIn: _fromBackendsToDataBusIn,
        data: data,
      ),
      errorsAreFatal: false,
      // TODO(alphamikle): Pass other arguments too
    );
    await backendInitializerCompleter.future;
    await subscription.cancel();
    _isolates[poolId] = IsolateContainer(
      isolate: isolate,
      isolatesIds: {
        _generateBackendIdFromType(B),
      },
      backendOut: backendOut,
      backendIn: frontendToBackendIn,
    );
    print('"$B" was created in pool $poolId');
    return BackendCreateResult(backendOut: backendOut, frontendIn: frontendToBackendIn, poolId: poolId);
  }

  Future<void> _createDataBus() async {
    if (_isDataBusCreating) {
      while (_isDataBusCreating) {
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }
      return;
    }
    _isDataBusCreating = true;
    final Completer<void> dataBusInitializerCompleter = Completer();
    final Out tempDataBusOut = OutNative<dynamic>();

    void listener(dynamic data) {
      if (data is DataBusInitResult) {
        _fromBackendsToDataBusIn = data.backendToDataBusIn;
        dataBusInitializerCompleter.complete();
      } else {
        throw Exception('Got incorrect message from DataBus in Isolate initializer');
      }
    }

    tempDataBusOut.listen(listener);
    _dataBusIsolate = await Isolate.spawn(
      createDataBus,
      tempDataBusOut.createIn,
      errorsAreFatal: true,
    );
    await dataBusInitializerCompleter.future;
    _isDataBusCreating = false;
    _isDataBusCreated = true;
  }

  Future<void> _closeContainerOfIsolates(int poolId) async {
    final IsolateContainer container = _isolates[poolId]!;
    await container.backendOut.close();
    container.isolate.kill();
    _isolates.remove(poolId);
    _freedPoolIds.add(poolId);
  }

  Future<BackendCreateResult> _addBackendToExistIsolate() async {
    // TODO(alphamikle): Add backend to existence isolate
    throw UnimplementedError();
  }

  Future<void> _closeBackendFromPool({
    required Type backendType,
    required int poolId,
  }) async {
    // TODO(alphamikle): Remove backend from pool
    throw UnimplementedError();
  }

  bool _isPoolExist(IsolatePoolId poolId) => _isolates.containsKey(poolId);

  String _generateBackendIdFromType(Type backendType) => '$backendType';
}

Isolator createIsolator() => IsolatorNative();
