import 'dart:async';
import 'dart:isolate';

import 'package:isolator/next/backend/backend_argument.dart';
import 'package:isolator/next/backend/backend_create_result.dart';
import 'package:isolator/next/backend/backend_init_result.dart';
import 'package:isolator/next/in/in_abstract.dart';
import 'package:isolator/next/isolator/isolate_container.dart';
import 'package:isolator/next/isolator/isolator_abstract.dart';
import 'package:isolator/next/out/out_abstract.dart';
import 'package:isolator/next/out/out_native.dart';
import 'package:isolator/next/types.dart';

int _poolId = 0;

class IsolatorNative implements Isolator {
  factory IsolatorNative() => _instance ??= IsolatorNative._();
  IsolatorNative._();

  static IsolatorNative? _instance;
  static final Map<IsolatePoolId, IsolateContainer?> _isolates = {};
  static late final Isolate _dataBusIsolate;
  static late final In _dataBusIn;
  static bool _isDataBusCreating = false;
  static bool _isDataBusCreated = false;

  @override
  Future<BackendCreateResult> isolate<T>({
    required BackendInitializer<T> initializer,
    required Type backendType,
    IsolatePoolId? poolId,
    T? data,
  }) async {
    if (!_isDataBusCreated) {
      await _createDataBus();
    }
    final int pid = poolId ?? _poolId++;
    if (_isPoolExist(pid)) {
      return _addBackendToExistIsolate();
    }
    return _createNewIsolate<T>(
      initializer: initializer,
      backendType: backendType,
      poolId: pid,
      data: data,
    );
  }

  Future<BackendCreateResult> _createNewIsolate<T>({
    required BackendInitializer<T> initializer,
    required Type backendType,
    required IsolatePoolId poolId,
    T? data,
  }) async {
    _isolates[poolId] = null;
    final Out<dynamic> backendOut = OutNative<dynamic>();
    late final In frontendToBackendIn;
    final Completer<void> backendInitializerCompleter = Completer<void>();
    void listener(dynamic data) {
      if (data is BackendInitResult) {
        frontendToBackendIn = data.frontendToBackendIn;
        _dataBusIn.send(data.dataBusToBackendIn);
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
        toDataBusIn: _dataBusIn,
        data: data,
      ),
    );
    await backendInitializerCompleter.future;
    await subscription.cancel();
    _isolates[poolId] = IsolateContainer(
      isolate: isolate,
      isolateId: backendType.toString(),
      backendOut: backendOut,
      backendIn: frontendToBackendIn,
    );
    print('Backend "$backendType" was created in pool $poolId');
    return BackendCreateResult(backendOut: backendOut, frontendIn: frontendToBackendIn);
  }

  Future<void> _createDataBus() async {
    if (_isDataBusCreating) {
      while (_isDataBusCreating) {
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }
      return;
    }
    _isDataBusCreating = true;
    // TODO(alphamikle): Create data bus
    // final Isolate dataBusIsolate = await Isolate.spawn(, message);
    _dataBusIn = OutNative<dynamic>().createIn;
    _isDataBusCreating = false;
    _isDataBusCreated = true;
  }

  Future<BackendCreateResult> _addBackendToExistIsolate() async {
    // TODO(alphamikle): Add backend to existence isolate
    throw UnimplementedError();
  }

  bool _isPoolExist(IsolatePoolId poolId) => _isolates.containsKey(poolId);
}

Isolator createIsolator() => IsolatorNative();
