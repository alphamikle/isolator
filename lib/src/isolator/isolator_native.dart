import 'dart:async';
import 'dart:collection';
import 'dart:isolate';

import 'package:isolator/src/backend/backend.dart';
import 'package:isolator/src/backend/backend_argument.dart';
import 'package:isolator/src/backend/backend_create_result.dart';
import 'package:isolator/src/backend/backend_init_result.dart';
import 'package:isolator/src/backend/child_backend_closer.dart';
import 'package:isolator/src/backend/child_backend_initializer.dart';
import 'package:isolator/src/constants.dart';
import 'package:isolator/src/data_bus/data_bus.dart';
import 'package:isolator/src/data_bus/data_bus_backend_init_message.dart';
import 'package:isolator/src/data_bus/data_bus_init_result.dart';
import 'package:isolator/src/in/in_abstract.dart';
import 'package:isolator/src/isolator/isolate_container.dart';
import 'package:isolator/src/isolator/isolator_abstract.dart';
import 'package:isolator/src/out/out_abstract.dart';
import 'package:isolator/src/tools/helpers.dart';
import 'package:isolator/src/types.dart';

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
  Future<BackendCreateResult> isolate<T, B extends Backend>({
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
      return _addBackendToExistIsolate<T, B>(initializer: initializer, poolId: pid, data: data);
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
    int counter = 0;
    while (_isPoolExist(poolId) && _isolates[poolId]?.isSomethingClosing == true ||
        !_isPoolExist(poolId)) {
      await wait(DEFAULT_WAIT_DELAY_MS);
      counter++;
      if (counter > 1000) {
        throw Exception('Cant close isolate $backendType from poolId = $poolId');
      }
    }
    if (!_isPoolExist(poolId)) {
      return;
    }
    container.isSomethingClosing = true;
    if (container.isolatesIds.length == 1) {
      await _closeContainerOfIsolates(poolId);
    } else {
      await _closeBackendFromPool(backendType: backendType, poolId: poolId);
    }
    container.isSomethingClosing = false;
  }

  Future<BackendCreateResult> _createNewIsolate<T, B extends Backend>({
    required BackendInitializer<T, B> initializer,
    required IsolatePoolId poolId,
    T? data,
  }) async {
    _isolates[poolId] = null;
    final Out<dynamic> backendOut = Out.create<dynamic>();
    late final In frontendToBackendIn;
    final Completer<void> backendInitializerCompleter = Completer();
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
      errorsAreFatal: true,
      // TODO(alphamikle): Pass other arguments too
    );
    await backendInitializerCompleter.future;
    await subscription.cancel();
    final String isolateId = _generateBackendIdFromType(B);
    _isolates[poolId] = IsolateContainer(
      isolate: isolate,
      isolatesIds: {isolateId},
      mainIsolateId: isolateId,
      backendOut: backendOut,
      backendIn: frontendToBackendIn,
    );
    print('"$B" was created in pool $poolId');
    return BackendCreateResult(
        backendOut: backendOut, frontendIn: frontendToBackendIn, poolId: poolId);
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
    final Out tempDataBusOut = Out.create<dynamic>();

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

  Future<BackendCreateResult> _addBackendToExistIsolate<T, B extends Backend>({
    required BackendInitializer<T, B> initializer,
    required IsolatePoolId poolId,
    T? data,
  }) async {
    int checker = 0;
    late final IsolateContainer existContainer;
    while (_isolates[poolId] == null) {
      await wait(5);
      checker++;
      if (checker > 1000) {
        throw Exception('Cant get isolate from pool $poolId');
      }
    }
    existContainer = _isolates[poolId]!;
    existContainer.isolatesIds.add(_generateBackendIdFromType(B));
    final Out<dynamic> backendOut = Out.create<dynamic>();
    final Completer<void> backendInitializerCompleter = Completer<void>();
    late final In frontendToBackendIn;

    void listener(dynamic message) {
      if (message is BackendInitResult) {
        frontendToBackendIn = message.frontendToBackendIn;
        _fromBackendsToDataBusIn.send(
          DataBusBackendInitMessage(
            backendIn: message.dataBusToBackendIn,
            backendId: _generateBackendIdFromType(B),
            type: MessageType.add,
          ),
        );
        backendInitializerCompleter.complete();
      } else {
        throw Exception('Got incorrect message from Backend in Isolate child initializer');
      }
    }

    final StreamSubscription<dynamic> subscription = backendOut.listen(listener);
    existContainer.backendIn.send(
      ChildBackendInitializer(
        initializer: initializer,
        argument: BackendArgument(
          toFrontendIn: backendOut.createIn,
          toDataBusIn: _fromBackendsToDataBusIn,
          data: data,
        ),
        backendId: _generateBackendIdFromType(B),
      ),
    );
    await backendInitializerCompleter.future;
    await subscription.cancel();
    return BackendCreateResult(
        backendOut: backendOut, frontendIn: frontendToBackendIn, poolId: poolId);
  }

  Future<void> _closeBackendFromPool({
    required Type backendType,
    required int poolId,
  }) async {
    final IsolateContainer container = _isolates[poolId]!;
    final BackendId backendId = _generateBackendIdFromType(backendType);
    if (container.mainIsolateId == backendId) {
      throw Exception('''
Before close main Backend from pool $poolId with ID = $backendId
You need to close all child Backends: ${container.isolatesIds.where((String id) => id != backendId).join(',')}''');
    }
    _fromBackendsToDataBusIn.send(
      DataBusBackendInitMessage(
        backendId: backendId,
        type: MessageType.remove,
        backendIn: null,
      ),
    );
    container.backendIn.send(ChildBackendCloser(backendId: backendId));
    container.isolatesIds.remove(backendId);
  }

  bool _isPoolExist(IsolatePoolId poolId) => _isolates.containsKey(poolId);

  String _generateBackendIdFromType(Type backendType) => '$backendType';
}

Isolator createIsolator() => IsolatorNative();
