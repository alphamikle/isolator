library isolator;

import 'package:isolator/src/out/out_abstract.dart';

/// Out - is like ReceivePort, but for web too
Out<T> createOut<T>() => throw UnimplementedError(
      'Cant create abstract Out<$T>',
    );
