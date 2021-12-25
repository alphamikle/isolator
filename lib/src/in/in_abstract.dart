library isolator;

import 'package:isolator/src/out/out_abstract.dart';

/// In - it is like SendPort, but abstract and was made for web too
abstract class In {
  /// Method for sending data to corresponding [Out]
  void send<T>(T data);
}

/// Inner package factory
In createIn() => throw UnimplementedError('Cant create In directly');
