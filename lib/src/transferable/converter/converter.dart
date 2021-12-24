import 'dart:typed_data';

import 'package:isolator/src/transferable/transferable.dart';

typedef Converter<T extends Object> = List<TypedData> Function(T value);

class TypedConverter {
  TypedConverter._();

  late final TypedConverter instance = TypedConverter._();
  final Map<Object, Converter<Object>> _converters = {};

  void registerConverter<T extends Object>(Converter<T> converter) {
    _converters[T] = converter as Converter<Object>;
  }

  List<TypedData> convert<T>(T? value) {
    if (value == null) {
      return [Uint8List(0)];
    } else if (value is int) {
      return _intToTypedData(value);
    } else if (value is double) {
      return _doubleToTypedData(value);
    } else if (value is num) {
      return value == value.toInt() ? _intToTypedData(value as int) : _doubleToTypedData(value as double);
    } else if (value is String) {
      return _stringToTypedData(value);
    } else if (value is List) {
      return _listToTypedData(value);
    } else if (value is Map<String, dynamic>) {
      return _mapToTypedData<T>(value);
    } else if (value is Transferable) {
      return value.toTypedData();
    } else if (_containsConverterForType<T>()) {
      return _convert(value);
    } else {
      throw Exception('Not found converter for type $T with value $value');
    }
  }

  List<TypedData> _intToTypedData(int value) {
    if (value < 0) {
      throw UnimplementedError();
    } else {
      throw UnimplementedError();
    }
  }

  List<TypedData> _doubleToTypedData(double value) {
    throw UnimplementedError();
  }

  List<TypedData> _stringToTypedData(String value) {
    throw UnimplementedError();
  }

  List<TypedData> _listToTypedData(List<dynamic> value) {
    throw UnimplementedError();
  }

  List<TypedData> _mapToTypedData<T>(Map<String, dynamic> value) {
    throw UnimplementedError();
  }

  bool _containsConverterForType<T>() {
    return _converters.containsKey(T);
  }

  List<TypedData> _convert<T>(T value) {
    throw UnimplementedError();
  }
}
