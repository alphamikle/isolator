import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:isolator/next/transferable/transferable.dart';

@immutable
class MockData implements Transferable {
  const MockData({
    required this.field1,
    required this.field2,
    required this.field3,
    required this.field4,
    required this.field5,
    required this.field6,
    required this.field7,
    required this.field8,
    required this.field9,
    required this.field10,
  });

  final String field1;
  final String field2;
  final String field3;
  final String field4;
  final int field5;
  final int field6;
  final int field7;
  final int field8;
  final MockData? field9;
  final MockData? field10;

  @override
  List<Object?> get props => [field1, field2, field3, field4, field5, field6, field7, field8, field9, field10];

  @override
  TransferableTypedData toTransferableTypedData() {
    throw UnimplementedError();
  }

  @override
  List<TypedData> toTypedData() {
    throw UnimplementedError();
  }
}
