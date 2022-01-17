library isolator;

import 'package:isolator/src/backend/backend.dart';
import 'package:isolator/src/backend/backend_create_result.dart';
import 'package:isolator/src/isolator/create_isolator.dart'
    if (dart.library.isolate) 'package:isolator/src/isolator/isolator_native.dart'
    if (dart.library.js) 'package:isolator/src/isolator/isolator_web.dart';
import 'package:isolator/src/isolator/isolator_web.dart' as web;
import 'package:isolator/src/types.dart';

/// Class, which create Backend to its Frontend for web and native platforms
abstract class Isolator {
  static bool _isSingleThreadModeEnabled = false;

  /// This method will create Backend
  Future<BackendCreateResult> isolate<T, B extends Backend>({
    required BackendInitializer<T, B> initializer,
    IsolatePoolId? poolId,
    T? data,
  });

  /// And this will close
  Future<void> close({
    required Type backendType,
    required int poolId,
  });

  /// Getter for create [Isolator]
  static late final Isolator instance =
      _isSingleThreadModeEnabled ? web.createIsolator() : createIsolator();

  /// See global function [enableSingleThreadMode]
  static void enableSingleThreadMode() {
    _isSingleThreadModeEnabled = true;
  }
}
