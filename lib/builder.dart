library isolator.builder;

import 'package:build/build.dart';
import 'package:isolator/src/codegen/generator.dart';
import 'package:source_gen/source_gen.dart';

/// Builder factory for generated isolate proxies and backends.
Builder isolatedBuilder(BuilderOptions options) {
  return SharedPartBuilder(
    <Generator>[
      IsolatedGenerator(),
    ],
    'isolated',
  );
}
