import 'dart:isolate';

import 'package:isolator/next/in/in_abstract.dart';
import 'package:isolator/next/out/out_abstract.dart';

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
