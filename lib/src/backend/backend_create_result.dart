library isolator;

import 'package:isolator/src/in/in_abstract.dart';
import 'package:isolator/src/out/out_abstract.dart';
import 'package:meta/meta.dart';

/// Response from just created Backend
@immutable
class BackendCreateResult {
  /// Constructor
  const BackendCreateResult({
    required this.backendOut,
    required this.frontendIn,
    required this.poolId,
  });

  final Out backendOut;
  final In frontendIn;
  final int poolId;
}
