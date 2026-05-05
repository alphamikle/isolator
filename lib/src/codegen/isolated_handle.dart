library isolator;

/// Runtime contract implemented by generated isolate proxies.
abstract class IsolatedHandle {
  /// Releases the backend isolate and closes its communication channels.
  Future<void> destroy();
}
