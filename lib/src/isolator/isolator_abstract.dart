import 'package:isolator/src/backend/backend.dart';
import 'package:isolator/src/backend/backend_create_result.dart';
import 'package:isolator/src/isolator/create_isolator.dart'
    if (dart.library.isolate) 'package:isolator/src/isolator/isolator_native.dart'
    if (dart.library.js) 'package:isolator/src/isolator/isolator_web.dart';
import 'package:isolator/src/types.dart';

abstract class Isolator {
  Future<BackendCreateResult> isolate<T, B extends Backend>({
    required BackendInitializer<T, B> initializer,
    IsolatePoolId? poolId,
    T? data,
  });

  Future<void> close({
    required Type backendType,
    required int poolId,
  });

  static late final Isolator instance = createIsolator();
}