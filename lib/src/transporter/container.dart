library isolator;

import 'package:isolator/src/frontend/frontend.dart';
import 'package:isolator/src/in/in_abstract.dart';
import 'package:isolator/src/message.dart';

/// Class
class Container<Event, Data> {
  /// Inner helper class for Transporter
  const Container({
    required this.message,
    required this.toFrontendIn,
  });

  /// Message, which will be sent to [In]'s corresponding [Frontend]
  final Message<Event, Data> message;

  /// [In] of [Frontend]-consumer
  final In toFrontendIn;
}
