import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:isolator/src/types.dart';

@immutable
class CompleterKey {
  const CompleterKey({
    required this.backendFrom,
    required this.backendTo,
    required this.id,
  });

  final BackendId backendFrom;
  final BackendId backendTo;
  final String id;

  @override
  bool operator ==(Object other) {
    if (other is CompleterKey) {
      return other.id == id && other.backendTo == backendTo && other.backendFrom == backendFrom;
    }
    return false;
  }

  @override
  int get hashCode =>
      utf8.encode('$backendFrom$backendTo$id').fold(0, (int sum, int byte) => sum + (byte * byte));
}
