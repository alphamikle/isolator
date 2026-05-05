library isolator.codegen;

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:isolator/src/codegen/annotations.dart';
import 'package:source_gen/source_gen.dart';

/// Generates isolate proxies and backends for a single annotated logic class.
class IsolatedGenerator extends GeneratorForAnnotation<Isolated> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '`@isolated` can only be used on classes.',
        element: element,
      );
    }
    _validateClass(element);

    final constructor = _resolveConstructor(element);
    final methods = element.methods
        .where(
          (MethodElement method) => _isPublicDeclaredMethod(element, method),
        )
        .toList()
      ..sort((MethodElement a, MethodElement b) => a.name.compareTo(b.name));
    final remoteMethods = methods
        .where((MethodElement method) => !_isIgnoredMethod(method))
        .toList();

    if (remoteMethods.isEmpty) {
      throw InvalidGenerationSourceError(
        '`${element.name}` does not declare any public instance methods to '
        'generate. Add a public `Future` method or mark methods with '
        '`@isolatedIgnore` to opt them out intentionally.',
        element: element,
      );
    }

    final emitter = _Emitter(
      targetClass: element,
      constructor: constructor,
      methods: methods,
      remoteMethods: remoteMethods,
    );
    return emitter.generate();
  }

  void _validateClass(ClassElement element) {
    if (element.isAbstract) {
      throw InvalidGenerationSourceError(
        '`${element.name}` must be a concrete class in this MVP.',
        element: element,
      );
    }
    if (element.typeParameters.isNotEmpty) {
      throw InvalidGenerationSourceError(
        'Generic isolated classes are not supported yet.',
        element: element,
      );
    }

    for (final FieldElement field in element.fields) {
      if (field.isStatic || field.isPrivate || field.isSynthetic) {
        continue;
      }
      throw InvalidGenerationSourceError(
        'Public instance fields are not supported by `@isolated` yet. '
        'Found `${field.name}` in `${element.name}`.',
        element: field,
      );
    }

    for (final PropertyAccessorElement accessor in element.accessors) {
      if (accessor.enclosingElement != element ||
          accessor.isStatic ||
          accessor.isPrivate ||
          accessor.isSynthetic) {
        continue;
      }
      throw InvalidGenerationSourceError(
        'Public getters/setters are not supported by `@isolated` yet. '
        'Found `${accessor.displayName}` in `${element.name}`.',
        element: accessor,
      );
    }

    for (final MethodElement method in element.methods) {
      if (!_isPublicDeclaredMethod(element, method) ||
          _isIgnoredMethod(method)) {
        continue;
      }
      if (method.typeParameters.isNotEmpty) {
        throw InvalidGenerationSourceError(
          'Generic methods are not supported by `@isolated` yet. '
          'Found `${method.name}`.',
          element: method,
        );
      }
      if (!method.returnType.isDartAsyncFuture) {
        throw InvalidGenerationSourceError(
          'Public isolated methods must return `Future<T>` or `Future<void>`. '
          '`${method.name}` returns `${method.returnType.getDisplayString(withNullability: true)}`.',
          element: method,
        );
      }
      final DartType responseType = _futureValueType(method.returnType);
      if (_isUnsupportedNullableResponse(responseType)) {
        throw InvalidGenerationSourceError(
          'Nullable remote responses are not supported because the current '
          '`Maybe<T>` runtime cannot distinguish `null` from "no value". '
          'Method `${method.name}` returns `${method.returnType.getDisplayString(withNullability: true)}`.',
          element: method,
        );
      }
    }
  }

  ConstructorElement _resolveConstructor(ClassElement element) {
    final ConstructorElement? constructor = element.unnamedConstructor;
    if (constructor == null || constructor.isFactory || constructor.isPrivate) {
      throw InvalidGenerationSourceError(
        '`${element.name}` must expose a public unnamed generative constructor.',
        element: element,
      );
    }
    return constructor;
  }

  bool _isPublicDeclaredMethod(ClassElement element, MethodElement method) {
    if (method.enclosingElement != element) {
      return false;
    }
    if (method.isStatic || method.isPrivate || method.isOperator) {
      return false;
    }
    return true;
  }

  bool _isIgnoredMethod(MethodElement method) {
    return TypeChecker.fromRuntime(IsolatedIgnore).hasAnnotationOf(method);
  }

  DartType _futureValueType(DartType returnType) {
    final InterfaceType futureType = returnType as InterfaceType;
    if (futureType.typeArguments.isEmpty) {
      return futureType.element.library.typeProvider.dynamicType;
    }
    return futureType.typeArguments.first;
  }

  bool _isUnsupportedNullableResponse(DartType type) {
    if (type is VoidType) {
      return false;
    }
    return type.nullabilitySuffix == NullabilitySuffix.question;
  }
}

class _Emitter {
  _Emitter({
    required this.targetClass,
    required this.constructor,
    required this.methods,
    required this.remoteMethods,
  });

  final ClassElement targetClass;
  final ConstructorElement constructor;
  final List<MethodElement> methods;
  final List<MethodElement> remoteMethods;

  String get _targetName => targetClass.name;
  String get _proxyName => '${targetClass.name}Isolate';
  String get _factoryName => 'create${targetClass.name}Isolate';
  String get _backendName => '_\$${targetClass.name}Backend';
  String get _backendFactoryName => '_\$create${targetClass.name}Backend';
  String get _eventEnumName => '_\$${targetClass.name}Event';
  String get _initName => '_\$${targetClass.name}Init';

  String generate() {
    final StringBuffer buffer = StringBuffer()
      ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
      ..writeln()
      ..writeln('class $_proxyName with Frontend implements IsolatedHandle {')
      ..writeln('  $_proxyName._();')
      ..writeln()
      ..writeln('  Future<void> _init({')
      ..write(_indented(_initConfigParameterList(), 4))
      ..writeln('  }) async {')
      ..writeln('    await initBackend<$_initName, $_backendName>(')
      ..writeln('      initializer: $_backendFactoryName,')
      ..writeln('      poolId: poolId,')
      ..writeln(
          '      data: $_initName(${_argumentForwarding(constructor.parameters, useGeneratedNamesForValues: true)}),')
      ..writeln('    );')
      ..writeln('  }')
      ..writeln()
      ..writeln('  @override')
      ..writeln('  void initActions() {}')
      ..writeln()
      ..writeln('  @override')
      ..writeln('  Future<void> destroy() async {')
      ..writeln('    await super.destroy();')
      ..writeln('  }')
      ..writeln();

    for (final MethodElement method in methods) {
      buffer
        ..write(
          remoteMethods.contains(method)
              ? _generateProxyMethod(method)
              : _generateIgnoredProxyMethod(method),
        )
        ..writeln();
    }

    buffer
      ..writeln('}')
      ..writeln()
      ..writeln(
          'Future<$_proxyName> $_factoryName(${_factorySignature()}) async {')
      ..writeln('  final frontend = $_proxyName._();')
      ..writeln('  await frontend._init(')
      ..writeln('    poolId: poolId,')
      ..write(_indented(_namedForwarding(constructor.parameters), 4))
      ..writeln('  );')
      ..writeln('  return frontend;')
      ..writeln('}')
      ..writeln()
      ..write(_generateEventEnum())
      ..writeln()
      ..write(_generateInitClass())
      ..writeln()
      ..write(_generateRequestClasses())
      ..write(_generateBackend())
      ..writeln()
      ..writeln('$_backendName $_backendFactoryName(')
      ..writeln('  BackendArgument<$_initName> argument,')
      ..writeln(') {')
      ..writeln('  return $_backendName(argument: argument);')
      ..writeln('}');

    return buffer.toString();
  }

  String _generateProxyMethod(MethodElement method) {
    final String returnType = method.returnType.getDisplayString(
      withNullability: true,
    );
    final DartType responseType = _futureValueType(method.returnType);
    final String responseTypeString = responseType is VoidType
        ? 'Object?'
        : responseType.getDisplayString(withNullability: true);
    final String requestType =
        method.parameters.isEmpty ? 'Object?' : _requestName(method);
    final String methodCall = method.parameters.isEmpty
        ? 'event: $_eventEnumName.${method.name},'
        : '''
event: $_eventEnumName.${method.name},
      data: ${_requestName(method)}(${_argumentForwarding(method.parameters)}),''';

    final StringBuffer buffer = StringBuffer()
      ..writeln(
          '  $returnType ${method.name}(${_parameterSignature(method.parameters)}) async {')
      ..writeln(
        '    final Maybe<$responseTypeString> response = await run<$_eventEnumName, $requestType, $responseTypeString>(',
      )
      ..writeln('      $methodCall')
      ..writeln('    );')
      ..writeln('    if (response.hasError) {')
      ..writeln('      throw response.error;')
      ..writeln('    }');

    if (responseType is! VoidType) {
      buffer.writeln('    return response.value;');
    }

    buffer..writeln('  }');
    return buffer.toString();
  }

  String _generateIgnoredProxyMethod(MethodElement method) {
    final String returnType = method.returnType.getDisplayString(
      withNullability: true,
    );
    return '''
  $returnType ${method.name}(${_parameterSignature(method.parameters)}) {
    throw UnsupportedError('Method `${method.name}` is marked with @isolatedIgnore and is unavailable on the generated isolate proxy.');
  }
''';
  }

  String _generateEventEnum() {
    final StringBuffer buffer = StringBuffer()
      ..writeln('enum $_eventEnumName {');
    for (final MethodElement method in remoteMethods) {
      buffer.writeln('  ${method.name},');
    }
    buffer.writeln('}');
    return buffer.toString();
  }

  String _generateInitClass() {
    return _generateArgumentClass(
      className: _initName,
      parameters: constructor.parameters,
    );
  }

  String _generateRequestClasses() {
    final StringBuffer buffer = StringBuffer();
    for (final MethodElement method in remoteMethods) {
      if (method.parameters.isEmpty) {
        continue;
      }
      buffer
        ..write(
          _generateArgumentClass(
            className: _requestName(method),
            parameters: method.parameters,
          ),
        )
        ..writeln();
    }
    return buffer.toString();
  }

  String _generateArgumentClass({
    required String className,
    required List<ParameterElement> parameters,
  }) {
    final StringBuffer buffer = StringBuffer()..writeln('class $className {');

    if (parameters.isEmpty) {
      buffer
        ..writeln('  const $className();')
        ..writeln('}');
      return buffer.toString();
    }

    for (final ParameterElement parameter in parameters) {
      buffer.writeln(
        '  final ${parameter.type.getDisplayString(withNullability: true)} ${parameter.name};',
      );
    }

    buffer
      ..writeln()
      ..writeln(
          '  const $className(${_fieldConstructorSignature(parameters)});')
      ..writeln('}');
    return buffer.toString();
  }

  String _generateBackend() {
    final StringBuffer buffer = StringBuffer()
      ..writeln('class $_backendName extends Backend<$_initName> {')
      ..writeln('  $_backendName({')
      ..writeln('    required BackendArgument<$_initName> argument,')
      ..writeln('  })  : _target = _createTarget(argument.data),')
      ..writeln('        super(argument: argument);')
      ..writeln()
      ..writeln('  final $_targetName _target;')
      ..writeln()
      ..writeln('  static $_targetName _createTarget($_initName? data) {')
      ..writeln('    if (data == null) {')
      ..writeln(
        "      throw StateError('Missing initialization data for $_targetName isolate.');",
      )
      ..writeln('    }')
      ..writeln(
          '    return $_targetName(${_constructorCall(constructor.parameters)});')
      ..writeln('  }')
      ..writeln()
      ..writeln('  @override')
      ..writeln('  void initActions() {');

    for (final MethodElement method in remoteMethods) {
      buffer.writeln(
        '    whenEventCome($_eventEnumName.${method.name}).run(_${method.name});',
      );
    }

    buffer
      ..writeln('  }')
      ..writeln();

    for (final MethodElement method in remoteMethods) {
      buffer
        ..write(_generateBackendMethod(method))
        ..writeln();
    }

    buffer.writeln('}');
    return buffer.toString();
  }

  String _generateBackendMethod(MethodElement method) {
    final DartType responseType = _futureValueType(method.returnType);
    final bool isVoid = responseType is VoidType;
    final String backendReturnType = isVoid
        ? 'Future<Object?>'
        : 'Future<${responseType.getDisplayString(withNullability: true)}>';
    final String requestType =
        method.parameters.isEmpty ? 'Object?' : _requestName(method);

    final StringBuffer buffer = StringBuffer()
      ..writeln(
        '  $backendReturnType _${method.name}({required $_eventEnumName event, required $requestType data}) async {',
      );

    final String invocation =
        '_target.${method.name}(${_invocationArguments(method.parameters)})';
    if (isVoid) {
      buffer
        ..writeln('    await $invocation;')
        ..writeln('    return null;');
    } else {
      buffer.writeln('    return await $invocation;');
    }

    buffer.writeln('  }');
    return buffer.toString();
  }

  DartType _futureValueType(DartType returnType) {
    final InterfaceType futureType = returnType as InterfaceType;
    if (futureType.typeArguments.isEmpty) {
      return targetClass.library.typeProvider.dynamicType;
    }
    return futureType.typeArguments.first;
  }

  String _requestName(MethodElement method) {
    final String capitalized =
        method.name.substring(0, 1).toUpperCase() + method.name.substring(1);
    return '_\$${_targetName}${capitalized}Request';
  }

  String _initConfigParameterList() {
    final List<String> lines = <String>[
      'int? poolId,',
    ];
    for (final ParameterElement parameter in constructor.parameters) {
      lines.add('${_namedConfigParameterDeclaration(parameter)},');
    }
    return lines.map((String line) => '$line\n').join();
  }

  String _factorySignature() {
    final List<ParameterElement> parameters = constructor.parameters;
    final List<ParameterElement> requiredPositional = parameters
        .where((ParameterElement parameter) => parameter.isRequiredPositional)
        .toList();
    final List<ParameterElement> optionalPositional = parameters
        .where((ParameterElement parameter) => parameter.isOptionalPositional)
        .toList();
    final List<ParameterElement> named = parameters
        .where((ParameterElement parameter) => parameter.isNamed)
        .toList();

    final List<String> parts = <String>[
      ...requiredPositional.map(_parameterDeclaration),
    ];

    if (optionalPositional.isNotEmpty) {
      parts.add(
        '[${optionalPositional.map(_parameterDeclaration).join(', ')}]',
      );
    }

    final List<String> namedDeclarations = <String>[
      ...named.map(_parameterDeclaration),
      'int? poolId',
    ];
    parts.add('{${namedDeclarations.join(', ')}}');

    return parts.join(', ');
  }

  String _parameterSignature(List<ParameterElement> parameters) {
    if (parameters.isEmpty) {
      return '';
    }
    final List<ParameterElement> requiredPositional = parameters
        .where((ParameterElement parameter) => parameter.isRequiredPositional)
        .toList();
    final List<ParameterElement> optionalPositional = parameters
        .where((ParameterElement parameter) => parameter.isOptionalPositional)
        .toList();
    final List<ParameterElement> named = parameters
        .where((ParameterElement parameter) => parameter.isNamed)
        .toList();

    final List<String> parts = <String>[
      ...requiredPositional.map(_parameterDeclaration),
    ];

    if (optionalPositional.isNotEmpty) {
      parts.add(
        '[${optionalPositional.map(_parameterDeclaration).join(', ')}]',
      );
    }

    if (named.isNotEmpty) {
      parts.add(
        '{${named.map(_parameterDeclaration).join(', ')}}',
      );
    }

    return parts.join(', ');
  }

  String _parameterDeclaration(ParameterElement parameter) {
    final String type = parameter.type.getDisplayString(withNullability: true);
    final String defaultValue = parameter.defaultValueCode == null
        ? ''
        : ' = ${parameter.defaultValueCode}';
    if (parameter.isNamed) {
      final String requiredPrefix =
          parameter.isRequiredNamed ? 'required ' : '';
      return '$requiredPrefix$type ${parameter.name}$defaultValue';
    }
    return '$type ${parameter.name}$defaultValue';
  }

  String _namedConfigParameterDeclaration(ParameterElement parameter) {
    final String type = parameter.type.getDisplayString(withNullability: true);
    final String defaultValue = parameter.defaultValueCode == null
        ? ''
        : ' = ${parameter.defaultValueCode}';
    final bool isRequired =
        parameter.isRequiredPositional || parameter.isRequiredNamed;
    final String requiredPrefix = isRequired ? 'required ' : '';
    return '$requiredPrefix$type ${_generatedParameterName(parameter)}$defaultValue';
  }

  String _fieldConstructorSignature(List<ParameterElement> parameters) {
    final List<ParameterElement> requiredPositional = parameters
        .where((ParameterElement parameter) => parameter.isRequiredPositional)
        .toList();
    final List<ParameterElement> optionalPositional = parameters
        .where((ParameterElement parameter) => parameter.isOptionalPositional)
        .toList();
    final List<ParameterElement> named = parameters
        .where((ParameterElement parameter) => parameter.isNamed)
        .toList();

    final List<String> pieces = <String>[
      ...requiredPositional.map(_fieldParameterDeclaration),
    ];

    if (optionalPositional.isNotEmpty) {
      pieces.add(
          '[${optionalPositional.map(_fieldParameterDeclaration).join(', ')}]');
    }

    if (named.isNotEmpty) {
      pieces.add('{${named.map(_fieldParameterDeclaration).join(', ')}}');
    }

    return pieces.join(', ');
  }

  String _fieldParameterDeclaration(ParameterElement parameter) {
    final String defaultValue = parameter.defaultValueCode == null
        ? ''
        : ' = ${parameter.defaultValueCode}';
    if (parameter.isNamed) {
      final String requiredPrefix =
          parameter.isRequiredNamed ? 'required ' : '';
      return '$requiredPrefix this.${parameter.name}$defaultValue';
    }
    return 'this.${parameter.name}$defaultValue';
  }

  String _argumentForwarding(
    List<ParameterElement> parameters, {
    bool useGeneratedNamesForValues = false,
  }) {
    if (parameters.isEmpty) {
      return '';
    }
    return parameters.map((ParameterElement parameter) {
      final String valueName = useGeneratedNamesForValues
          ? _generatedParameterName(parameter)
          : parameter.name;
      if (parameter.isNamed) {
        return '${parameter.name}: $valueName';
      }
      return valueName;
    }).join(', ');
  }

  String _namedForwarding(List<ParameterElement> parameters) {
    if (parameters.isEmpty) {
      return '';
    }
    return parameters.map((ParameterElement parameter) {
      return '${_generatedParameterName(parameter)}: ${parameter.name},\n';
    }).join();
  }

  String _constructorCall(List<ParameterElement> parameters) {
    if (parameters.isEmpty) {
      return '';
    }
    return parameters.map((ParameterElement parameter) {
      if (parameter.isNamed) {
        return '${parameter.name}: data.${parameter.name}';
      }
      return 'data.${parameter.name}';
    }).join(', ');
  }

  String _invocationArguments(List<ParameterElement> parameters) {
    if (parameters.isEmpty) {
      return '';
    }
    return parameters.map((ParameterElement parameter) {
      if (parameter.isNamed) {
        return '${parameter.name}: data.${parameter.name}';
      }
      return 'data.${parameter.name}';
    }).join(', ');
  }

  String _indented(String input, int spaces) {
    final String prefix = ' ' * spaces;
    return input
        .split('\n')
        .where((String line) => line.isNotEmpty)
        .map((String line) => '$prefix$line\n')
        .join();
  }

  String _generatedParameterName(ParameterElement parameter) {
    final String sanitized = parameter.name.replaceFirst(RegExp(r'^_+'), '');
    if (sanitized.isEmpty) {
      return 'arg';
    }
    return sanitized;
  }
}
