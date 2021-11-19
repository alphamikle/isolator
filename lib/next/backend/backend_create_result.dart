import 'package:flutter/foundation.dart';
import 'package:isolator/next/in/in_abstract.dart';
import 'package:isolator/next/out/out_abstract.dart';

@immutable
class BackendCreateResult {
  const BackendCreateResult({
    required this.backendOut,
    required this.frontendIn,
    required this.poolId,
  });

  final Out backendOut;
  final In frontendIn;
  final int poolId;
}
