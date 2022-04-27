library isolator;

/// Class
class Packet<T> {
  /// Wrapper for sending several arguments to Backend or Frontend
  const Packet(
    this.value,
  );

  /// 2 arguments wrapper
  static Packet2 c2<T, T2>(
    T value,
    T2 value2,
  ) =>
      Packet2<T, T2>(
        value,
        value2,
      );

  /// 3 arguments wrapper
  static Packet3 c3<T, T2, T3>(
    T value,
    T2 value2,
    T3 value3,
  ) =>
      Packet3<T, T2, T3>(
        value,
        value2,
        value3,
      );

  /// 4 arguments wrapper
  static Packet4 c4<T, T2, T3, T4>(
    T value,
    T2 value2,
    T3 value3,
    T4 value4,
  ) =>
      Packet4<T, T2, T3, T4>(
        value,
        value2,
        value3,
        value4,
      );

  /// 5 arguments wrapper
  static Packet5 c5<T, T2, T3, T4, T5>(
    T value,
    T2 value2,
    T3 value3,
    T4 value4,
    T5 value5,
  ) =>
      Packet5<T, T2, T3, T4, T5>(
        value,
        value2,
        value3,
        value4,
        value5,
      );

  /// Wrapped value
  final T value;

  @override
  String toString() {
    return 'Packet{value: $value}';
  }
}

/// Class
class Packet2<T, T2> implements Packet<T> {
  /// Wrapper for sending 2 arguments to Backend or Frontend
  const Packet2(
    this.value,
    this.value2,
  );

  @override
  final T value;

  /// 2-th wrapped value
  final T2 value2;

  @override
  String toString() {
    return 'Packet2{value: $value, value2: $value2}';
  }
}

/// Class
class Packet3<T, T2, T3> implements Packet2<T, T2> {
  /// Wrapper for sending 3 arguments to Backend or Frontend
  const Packet3(
    this.value,
    this.value2,
    this.value3,
  );

  @override
  final T value;

  @override
  final T2 value2;

  /// 3-th wrapped value
  final T3 value3;

  @override
  String toString() {
    return 'Packet3{value: $value, value2: $value2, value3: $value3}';
  }
}

/// Class
class Packet4<T, T2, T3, T4> implements Packet3<T, T2, T3> {
  /// Wrapper for sending 4 arguments to Backend or Frontend
  const Packet4(
    this.value,
    this.value2,
    this.value3,
    this.value4,
  );

  @override
  final T value;

  @override
  final T2 value2;

  @override
  final T3 value3;

  /// 4-th wrapped value
  final T4 value4;

  @override
  String toString() {
    return '''Packet4{value: $value, value2: $value2, value3: $value3, value4: $value4}''';
  }
}

/// Class
class Packet5<T, T2, T3, T4, T5> implements Packet4<T, T2, T3, T4> {
  /// Wrapper for sending 5 arguments to Backend or Frontend
  const Packet5(
    this.value,
    this.value2,
    this.value3,
    this.value4,
    this.value5,
  );

  @override
  final T value;

  @override
  final T2 value2;

  @override
  final T3 value3;

  @override
  final T4 value4;

  /// 5-th wrapped value
  final T5 value5;

  @override
  String toString() {
    return '''Packet5{value: $value, value2: $value2, value3: $value3, value4: $value4, value5: $value5}''';
  }
}

/// Class
class Packet6<T, T2, T3, T4, T5, T6> implements Packet5<T, T2, T3, T4, T5> {
  /// Wrapper for sending 6 arguments to Backend or Frontend
  const Packet6(
    this.value,
    this.value2,
    this.value3,
    this.value4,
    this.value5,
    this.value6,
  );

  @override
  final T value;

  @override
  final T2 value2;

  @override
  final T3 value3;

  @override
  final T4 value4;

  @override
  final T5 value5;

  /// 6-th wrapped value
  final T6 value6;

  @override
  String toString() {
    return '''Packet5{value: $value, value2: $value2, value3: $value3, value4: $value4, value5: $value5, value6: $value6}''';
  }
}

/// Class
class Packet7<T, T2, T3, T4, T5, T6, T7>
    implements Packet6<T, T2, T3, T4, T5, T6> {
  /// Wrapper for sending 7 arguments to Backend or Frontend
  const Packet7(
    this.value,
    this.value2,
    this.value3,
    this.value4,
    this.value5,
    this.value6,
    this.value7,
  );

  @override
  final T value;

  @override
  final T2 value2;

  @override
  final T3 value3;

  @override
  final T4 value4;

  @override
  final T5 value5;

  @override
  final T6 value6;

  /// 7-th wrapped value
  final T7 value7;

  @override
  String toString() {
    return '''Packet5{value: $value, value2: $value2, value3: $value3, value4: $value4, value5: $value5, value6: $value6, value7: $value7}''';
  }
}

/// Class
class Packet8<T, T2, T3, T4, T5, T6, T7, T8>
    implements Packet7<T, T2, T3, T4, T5, T6, T7> {
  /// Wrapper for sending 8 arguments to Backend or Frontend
  const Packet8(
    this.value,
    this.value2,
    this.value3,
    this.value4,
    this.value5,
    this.value6,
    this.value7,
    this.value8,
  );

  @override
  final T value;

  @override
  final T2 value2;

  @override
  final T3 value3;

  @override
  final T4 value4;

  @override
  final T5 value5;

  @override
  final T6 value6;

  @override
  final T7 value7;

  /// 8-th wrapped value
  final T8 value8;

  @override
  String toString() {
    return '''Packet5{value: $value, value2: $value2, value3: $value3, value4: $value4, value5: $value5, value6: $value6, value7: $value7, value8: $value8}''';
  }
}

/// Class
class Packet9<T, T2, T3, T4, T5, T6, T7, T8, T9>
    implements Packet8<T, T2, T3, T4, T5, T6, T7, T8> {
  /// Wrapper for sending 9 arguments to Backend or Frontend
  const Packet9(
    this.value,
    this.value2,
    this.value3,
    this.value4,
    this.value5,
    this.value6,
    this.value7,
    this.value8,
    this.value9,
  );

  @override
  final T value;

  @override
  final T2 value2;

  @override
  final T3 value3;

  @override
  final T4 value4;

  @override
  final T5 value5;

  @override
  final T6 value6;

  @override
  final T7 value7;

  @override
  final T8 value8;

  /// 9-th wrapped value
  final T9 value9;

  @override
  String toString() {
    return '''Packet5{value: $value, value2: $value2, value3: $value3, value4: $value4, value5: $value5, value6: $value6, value7: $value7, value8: $value8, value9: $value9}''';
  }
}

/// Class
class Packet10<T, T2, T3, T4, T5, T6, T7, T8, T9, T10>
    implements Packet9<T, T2, T3, T4, T5, T6, T7, T8, T9> {
  /// Wrapper for sending 10 arguments to Backend or Frontend
  const Packet10(
    this.value,
    this.value2,
    this.value3,
    this.value4,
    this.value5,
    this.value6,
    this.value7,
    this.value8,
    this.value9,
    this.value10,
  );

  @override
  final T value;

  @override
  final T2 value2;

  @override
  final T3 value3;

  @override
  final T4 value4;

  @override
  final T5 value5;

  @override
  final T6 value6;

  @override
  final T7 value7;

  @override
  final T8 value8;

  @override
  final T9 value9;

  /// 10-th wrapped value
  final T10 value10;

  @override
  String toString() {
    return '''Packet5{value: $value, value2: $value2, value3: $value3, value4: $value4, value5: $value5, value6: $value6, value7: $value7, value8: $value8, value9: $value9, value10: $value10}''';
  }
}
