void main() {
  const function = f1 as Function;
  const function2 = f2 as Function;
  function(first: 1, second: 2);
  function2(first: 1, second: 2);
}

void f1({required int first, required int second}) {
  print('$first | $second');
}

void f2({required int first}) {
  print(first);
}
