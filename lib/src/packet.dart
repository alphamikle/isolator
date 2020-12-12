class Packet<T> {
  const Packet(this.value);

  static Packet2 c2<T, T2>(T value, T2 value2) => Packet2<T, T2>(value, value2);
  static Packet3 c3<T, T2, T3>(T value, T2 value2, T3 value3) => Packet3<T, T2, T3>(value, value2, value3);
  static Packet4 c4<T, T2, T3, T4>(T value, T2 value2, T3 value3, T4 value4) => Packet4<T, T2, T3, T4>(value, value2, value3, value4);
  static Packet5 c5<T, T2, T3, T4, T5>(T value, T2 value2, T3 value3, T4 value4, T5 value5) => Packet5<T, T2, T3, T4, T5>(value, value2, value3, value4, value5);

  final T value;
}

class Packet2<T, T2> {
  const Packet2(this.value, this.value2);

  final T value;
  final T2 value2;
}

class Packet3<T, T2, T3> {
  const Packet3(this.value, this.value2, this.value3);

  final T value;
  final T2 value2;
  final T3 value3;
}

class Packet4<T, T2, T3, T4> {
  const Packet4(this.value, this.value2, this.value3, this.value4);

  final T value;
  final T2 value2;
  final T3 value3;
  final T4 value4;
}

class Packet5<T, T2, T3, T4, T5> {
  const Packet5(this.value, this.value2, this.value3, this.value4, this.value5);

  final T value;
  final T2 value2;
  final T3 value3;
  final T4 value4;
  final T5 value5;
}
