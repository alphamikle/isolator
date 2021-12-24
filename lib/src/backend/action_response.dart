import 'package:isolator/src/backend/chunks.dart';

class ActionResponse<T> {
  ActionResponse.empty()
      : _chunks = null,
        _list = null,
        _value = null,
        timestamp = DateTime.now();

  ActionResponse.chunks(Chunks<T> chunks)
      : _chunks = chunks,
        _list = null,
        _value = null,
        timestamp = DateTime.now();

  ActionResponse.value(T value)
      : _chunks = null,
        _list = null,
        _value = value,
        timestamp = DateTime.now();

  ActionResponse.list(List<T> list)
      : _chunks = null,
        _list = list,
        _value = null,
        timestamp = DateTime.now();

  final Chunks<T>? _chunks;
  final List<T>? _list;
  final T? _value;
  final DateTime timestamp;

  bool get isChunks => _chunks != null;

  bool get isList => _list != null;

  bool get isValue => _value != null;

  bool get isEmpty => _chunks == null && _list == null && _value == null;

  Chunks<T> get chunks => _chunks!;

  List<T> get list => _list!;

  T get value => _value!;

  @override
  String toString() => '$runtimeType: { chunks: $_chunks, list: $_list, value: $_value }';
}
