import 'package:isolator/src/isolator/isolator_abstract.dart';

/// In some versions of Flutter you can see, that Hot Reload take a
/// very much time.
/// See: https://github.com/flutter/flutter/issues/84347
/// And this:https://github.com/flutter/flutter/pull/84363
/// To solve this problem - you must have as least isolates
/// as possible and with this method you can use Isolator in single thread
/// mode for developing, to have fast Hot Reload as usual and enable
/// multi-thread (standard) mode only for checking that all works fine
/// and for production.
void enableSingleThreadMode() {
  Isolator.enableSingleThreadMode();
}
