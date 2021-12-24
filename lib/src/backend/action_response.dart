class ActionResponse<T> {
  ActionResponse.empty()
      : _list = null,
        _value = null,
        timestamp = DateTime.now();

  ActionResponse.value(T value)
      : _list = null,
        _value = value,
        timestamp = DateTime.now();

  ActionResponse.list(List<T> list)
      : _list = list,
        _value = null,
        timestamp = DateTime.now();
  final List<T>? _list;
  final T? _value;
  final DateTime timestamp;

  bool get isList => _list != null;

  bool get isValue => _value != null;

  bool get isEmpty => _list == null && _value == null;

  List<T> get list => _list!;

  T get value => _value!;

  @override
  String toString() => '$runtimeType: { list: $_list, value: $_value }';
}
