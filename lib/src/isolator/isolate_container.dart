library isolator;

import 'dart:isolate';

import 'package:isolator/src/backend/backend.dart';
import 'package:isolator/src/in/in_abstract.dart';
import 'package:isolator/src/isolator/isolator_abstract.dart';
import 'package:isolator/src/out/out_abstract.dart';

/// Class
class IsolateContainer {
  /// Wrapper to hold native isolates in [Isolator] instance
  IsolateContainer({
    required this.isolate,
    required this.isolatesIds,
    required this.mainIsolateId,
    required this.backendOut,
    required this.backendIn,
  });

  /// Instance of isolate
  final Isolate isolate;

  /// List of isolates ids, which was launched in the same pool
  final Set<String> isolatesIds;

  /// ID of the first isolate in the pool, which will be the main
  final String mainIsolateId;

  /// [Out] of the main isolate ([Backend])
  final Out backendOut;

  /// [In] of the main isolate ([Backend])
  final In backendIn;

  /// Status of the main isolate, if we closing some another
  /// isolate at this pool
  bool isSomethingClosing = false;
}
