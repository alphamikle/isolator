library isolator;

/// Marks a class whose public instance methods should run in a worker isolate.
///
/// Supported classes in this MVP:
/// - concrete, non-generic classes
/// - a single public unnamed generative constructor
/// - public instance methods that return [Future] or [Future<void>]
/// - no public instance fields, getters, or setters
class Isolated {
  /// Marks a class for code generation.
  const Isolated();
}

/// Shorthand constant for [Isolated].
const Isolated isolated = Isolated();

/// Excludes a public instance method from the generated remote API.
class IsolatedIgnore {
  /// Excludes a public instance method from the generated remote API.
  const IsolatedIgnore();
}

/// Shorthand constant for [IsolatedIgnore].
const IsolatedIgnore isolatedIgnore = IsolatedIgnore();
