import 'package:isolator/next/backend/backend_create_result.dart';
import 'package:isolator/next/isolator/isolator_abstract.dart';
import 'package:isolator/next/types.dart';

class IsolatorWeb implements Isolator {
  factory IsolatorWeb() => _instance ??= IsolatorWeb._();
  IsolatorWeb._();

  static IsolatorWeb? _instance;

  @override
  Future<BackendCreateResult> isolate<T, B>({
    required BackendInitializer<T, B> initializer,
    IsolatePoolId? poolId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> close({
    required Type backendType,
    required int poolId,
  }) async {
    throw UnimplementedError();
  }
}

Isolator createIsolator() => IsolatorWeb();
