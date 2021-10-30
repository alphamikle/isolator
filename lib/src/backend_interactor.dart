part of 'isolator.dart';

abstract class InteractorOf<T extends Backend<dynamic>> {
  InteractorOf(this._backend);

  final Backend<dynamic> _backend;

  @protected
  void sendMessage(dynamic messageBusEventId, [dynamic value]) {
    _backend._sendMessageToAnotherBackend(T, messageBusEventId, value);
  }

  @protected
  Future<TResponse> runMethod<TResponse>(dynamic messageBusEventId, [dynamic value]) async {
    return _backend._runAnotherBackendMethod(T, messageBusEventId, value);
  }

  @protected
  Future<List<TResponse>> runMethodWithListResponse<TResponse>(dynamic messageBusEventId, [dynamic value]) async {
    return _backend._runAnotherBackendMethodWithListResponse(T, messageBusEventId, value);
  }
}

enum _ExampleEvent { init }

enum _ExampleAnotherEvent { init }

class _ExampleAnotherBackend extends Backend<_ExampleAnotherEvent> {
  _ExampleAnotherBackend(BackendArgument<void> argument) : super(argument);

  @override
  Map<_ExampleAnotherEvent, Function> get operations => {
        /// There are a list of operations, which available from Frontend ot this Backend
        /// And from another Backends too
      };

  @override
  Map<dynamic, Function> get busHandlers => <dynamic, Function>{
        /// There are a list of handlers, which available to call from another Backends
      };
}

class _AnotherBackendInteractor extends InteractorOf {
  _AnotherBackendInteractor(Backend backend) : super(backend);

  Future<String> getStatusOfAnotherBackend() async {
    final String result = await runMethod(_ExampleAnotherEvent.init);
    return result;
  }
}

class _ExampleBackend extends Backend<_ExampleEvent> {
  _ExampleBackend(BackendArgument<void> argument) : super(argument);

  _AnotherBackendInteractor get _anotherBackendInteractor => _AnotherBackendInteractor(this);

  Future<void> checkStatusAndStartSomething() async {
    final String status = await _anotherBackendInteractor.getStatusOfAnotherBackend();
    if (status == 'ok') {
      // DO SOMETHING
    }
  }

  @override
  Map<_ExampleEvent, Function> get operations => {};
}
