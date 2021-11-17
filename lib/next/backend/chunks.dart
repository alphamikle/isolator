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

  Chunks<T> copyWith({
    List<T>? data,
    Duration? delay,
    int? size,
    bool? updateAfterFirstChunk,
  }) {
    return Chunks<T>(
      data: data ?? this.data,
      delay: delay ?? this.delay,
      size: size ?? this.size,
      updateAfterFirstChunk: updateAfterFirstChunk ?? this.updateAfterFirstChunk,
    );
  }
}
