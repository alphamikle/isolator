import 'package:isolator/next/in/in_abstract.dart';

class InWeb implements In {
  late final Sink<dynamic> _sink;

  @override
  void send<T>(T data) => _sink.add(data);

  void initSink(Sink<dynamic> sink) => _sink = sink;
}

In createIn() => InWeb();
