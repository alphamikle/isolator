import 'dart:async';

import 'package:isolator/src/in/in_abstract.dart';
import 'package:isolator/src/out/create_out.dart'
    if (dart.library.isolate) 'package:isolator/src/out/out_native.dart'
    if (dart.library.js) 'package:isolator/src/out/out_web.dart';
import 'package:isolator/src/types.dart';

abstract class Out<T> {
  In get createIn => throw UnimplementedError('Cant create In from abstract Out');

  StreamSubscription<T> listen(
    StreamDataListener<T> onData, {
    StreamErrorListener? onError,
    StreamOnDoneCallback? onDone,
    bool cancelOnError = false,
  });

  Future<void> close();

  static Out<T> create<T>() => createOut<T>();
}
