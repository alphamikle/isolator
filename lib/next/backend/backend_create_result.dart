import 'package:flutter/foundation.dart';
import 'package:isolator/next/in/in_abstract.dart';
import 'package:isolator/next/out/out_abstract.dart';

@immutable
class BackendCreateResult {
  const BackendCreateResult({
    required this.backendOut,
    required this.frontendIn,
  });

  final Out backendOut;
  final In frontendIn;
}
