import 'package:isolator/src/in/in_abstract.dart';
import 'package:isolator/src/message.dart';

class Container<Event, Data> {
  const Container({
    required this.message,
    required this.toFrontendIn,
  });

  final Message<Event, Data> message;
  final In toFrontendIn;
}
