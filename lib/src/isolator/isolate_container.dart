import 'dart:isolate';

import 'package:isolator/src/in/in_abstract.dart';
import 'package:isolator/src/out/out_abstract.dart';

/// Wrapper to hold native isolates in Isolator instance
class IsolateContainer {
  IsolateContainer({
    required this.isolate,
    required this.isolatesIds,
    required this.mainIsolateId,
    required this.backendOut,
    required this.backendIn,
  });

  final Isolate isolate;
  final Set<String> isolatesIds;
  final String mainIsolateId;
  final Out backendOut;
  final In backendIn;
  bool isSomethingClosing = false;
}
