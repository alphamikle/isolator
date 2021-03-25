part of 'isolator.dart';

mixin BackendInitMixin<TEvent> {
  bool _isInitialized = false;

  late Completer<bool> _initializerCompleter;

  /// Hook on start backend
  @protected
  @mustCallSuper
  Future<void> init() async {
    _isInitialized = true;
    _initializerCompleter.complete(true);
  }

  /// Check, if backend was initialized in timeout (can be helpful, when you place complex logic in [init] method of backend
  void _checkInitialization() {
    Future<void>.delayed(IsolatorConfig._instance.backendInitTimeout, () {
      if (!_isInitialized) {
        throw Exception('$runtimeType not initialized in ${IsolatorConfig._instance.backendInitTimeout.inMilliseconds}ms');
      } else if (IsolatorConfig._instance.logEvents) {
        print('[$runtimeType] Was completely initialized');
      }
    });
  }
}
