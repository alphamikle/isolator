import 'package:flutter/foundation.dart';

@immutable
class MockData {
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
}
