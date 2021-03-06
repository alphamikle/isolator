import 'package:flutter_test/flutter_test.dart';
import 'package:isolator/src/utils.dart';

class GenericMock<T> {}

class GenericMock2<T1, T2> {}

void withoutParams() => '';
void withOneParam(int param) => '';
void withTwoParams(int param1, int param2) => '';

void withOptionalParam([int? param]) => '';
void withTwoOptionalParam([int? param1, int? param2]) => '';
void withNamedParam({int? param}) => '';

void withOneGenericParam(GenericMock<int> param) => '';
void withOneGeneric2Param(GenericMock2<int, String> param) => '';
void withOneGeneric2DoubleParam(GenericMock2<int, GenericMock<int>> param) => '';

void withTwoGenericParams(GenericMock<int> param, GenericMock<String> param2) => '';

enum TestEvent {
  sendData,
}

void main() {
  group('Group of tests for $Utils', () {
    test('Test of ${Utils.isFunctionWithSeveralSimpleParams}', () {
      expect(Utils.isFunctionWithSeveralSimpleParams(withoutParams), false);
      expect(Utils.isFunctionWithSeveralSimpleParams(withOneParam), false);
      expect(Utils.isFunctionWithSeveralSimpleParams(withTwoParams), true);

      expect(Utils.isFunctionWithSeveralSimpleParams(withOptionalParam), false);
      expect(Utils.isFunctionWithSeveralSimpleParams(withTwoOptionalParam), true);
      expect(Utils.isFunctionWithSeveralSimpleParams(withNamedParam), false);

      expect(Utils.isFunctionWithSeveralSimpleParams(withOneGenericParam), false);
      expect(Utils.isFunctionWithSeveralSimpleParams(withOneGeneric2Param), false);
      expect(Utils.isFunctionWithSeveralSimpleParams(withOneGeneric2DoubleParam), false);
    });

    test('Test of ${Utils.isFunctionWithParam}', () {
      expect(Utils.isFunctionWithParam(withoutParams), false);
      expect(Utils.isFunctionWithParam(withOneParam), true);
      expect(Utils.isFunctionWithParam(withTwoParams), true);

      expect(Utils.isFunctionWithParam(withOptionalParam), true);
      expect(Utils.isFunctionWithParam(withTwoOptionalParam), true);
      expect(Utils.isFunctionWithParam(withNamedParam), true);

      expect(Utils.isFunctionWithParam(withOneGenericParam), true);
      expect(Utils.isFunctionWithParam(withOneGeneric2Param), true);
      expect(Utils.isFunctionWithParam(withOneGeneric2DoubleParam), true);
    });

    test('Test of ${Utils.isFunctionWithNamedParam}', () {
      expect(Utils.isFunctionWithNamedParam(withoutParams), false);
      expect(Utils.isFunctionWithNamedParam(withOneParam), false);
      expect(Utils.isFunctionWithNamedParam(withTwoParams), false);

      expect(Utils.isFunctionWithNamedParam(withOptionalParam), false);
      expect(Utils.isFunctionWithNamedParam(withTwoOptionalParam), false);
      expect(Utils.isFunctionWithNamedParam(withNamedParam), true);

      expect(Utils.isFunctionWithNamedParam(withOneGenericParam), false);
      expect(Utils.isFunctionWithNamedParam(withOneGeneric2Param), false);
      expect(Utils.isFunctionWithNamedParam(withOneGeneric2DoubleParam), false);
    });

    test('Test of ${Utils.isFunctionWithSeveralGenerics}', () {
      expect(Utils.isFunctionWithSeveralGenerics(withoutParams), false);
      expect(Utils.isFunctionWithSeveralGenerics(withOneParam), false);
      expect(Utils.isFunctionWithSeveralGenerics(withTwoParams), false);

      expect(Utils.isFunctionWithSeveralGenerics(withOptionalParam), false);
      expect(Utils.isFunctionWithSeveralGenerics(withTwoOptionalParam), false);
      expect(Utils.isFunctionWithSeveralGenerics(withNamedParam), false);

      expect(Utils.isFunctionWithSeveralGenerics(withOneGenericParam), false);
      expect(Utils.isFunctionWithSeveralGenerics(withOneGeneric2Param), false);
      expect(Utils.isFunctionWithSeveralGenerics(withOneGeneric2DoubleParam), false);

      expect(Utils.isFunctionWithSeveralGenerics(withTwoGenericParams), true);
    });

    test('Code generation', () {
      final String code = Utils.generateCode(TestEvent.sendData);
      final String idFromCode = Utils.getIdFromCode(code);
      expect(idFromCode, 'TestEvent.sendData');
    });
  });
}
