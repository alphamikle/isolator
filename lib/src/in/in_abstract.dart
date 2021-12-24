abstract class In {
  void send<T>(T data);
}

In createIn() => throw UnimplementedError('Cant create In directly');
