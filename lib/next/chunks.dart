import 'package:flutter/foundation.dart';

@immutable
class Chunks<T> {
  const Chunks({
    required this.data,
    this.delay = const Duration(milliseconds: 8),
    this.size = 20,
    this.updateAfterFirstChunk = false,
  });

  final List<T> data;
  final Duration delay;
  final int size;
  final bool updateAfterFirstChunk;
}
