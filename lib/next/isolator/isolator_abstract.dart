import 'package:isolator/next/backend/backend_create_result.dart';
import 'package:isolator/next/isolator/create_isolator.dart'
    if (dart.library.isolate) 'package:isolator/next/isolator/isolator_native.dart'
    if (dart.library.js) 'package:isolator/next/isolator/isolator_web.dart';
import 'package:isolator/next/types.dart';

abstract class Isolator {
  Future<BackendCreateResult> isolate<T>({
    required BackendInitializer<T> initializer,
    required Type backendType,
    IsolatePoolId? poolId,
  });

  static late final Isolator instance = createIsolator();
}