library isolator;

import 'dart:async';

import 'package:isolator/src/in/in_abstract.dart';
import 'package:isolator/src/out/create_out.dart'
    if (dart.library.isolate) 'package:isolator/src/out/out_native.dart'
    if (dart.library.js) 'package:isolator/src/out/out_web.dart';
import 'package:isolator/src/types.dart';

/// Out interface (seems like ReceivePort)
abstract class Out<T> {
  /// Creates the corresponding [In]
  In get createIn => throw UnimplementedError(
        'Cant create In from abstract Out',
      );

  /// Subscribe on events of type <T>, which will consume this [Out]
  StreamSubscription<T> listen(
    StreamDataListener<T> onData, {
    StreamErrorListener? onError,
    StreamOnDoneCallback? onDone,
    bool cancelOnError = false,
  });

  /// Closes this [Out]
  Future<void> close();

  /// Inner package factory
  static Out<T> create<T>() => createOut<T>();
}
