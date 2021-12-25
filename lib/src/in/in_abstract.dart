/// In - it is like SendPort, but abstract and was made for web too
abstract class In {
  void send<T>(T data);
}

In createIn() => throw UnimplementedError('Cant create In directly');
