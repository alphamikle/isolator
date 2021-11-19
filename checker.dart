void main() {
  map['str'] = str;
  map['vd'] = vd;
  final fn = map['str']! as Func<String>;
  final v = map['vd']! as Func<void>;
  print('<${fn.runtimeType}>$fn' + fn(data: 1));
}

typedef Func<T> = T Function({required int data});

String str({required int data}) {
  return 'STR: $data';
}

void vd({required int data}) {
  // DO NOTHING
}

final map = <String, Function>{};
