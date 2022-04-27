part of 'backend.dart';

/// Class
abstract class InteractorOf<BackendType extends Backend> {
  /// [InteractorOf<Backend>] - is a facade to communicate between [Backend]'s
  /// Only [InteractorOf] have access to private [Backend]'s method, which can
  /// be used to send data to another [Backend]
  ///
  /// How to use:
  /// See [SecondBackInteractor]
  /// in test/next/data_bus/second_back_interactor.dart
  InteractorOf(this._backend) : assert('$BackendType' != 'Backend');

  final Backend _backend;

  /// Method for using private [InteractorOf<Backend>] method to sending data
  /// to another [Backend]
  @protected
  Future<Maybe<Res>> run<Event, Req extends Object?, Res extends Object?>({
    required Event event,
    Req? data,
  }) async {
    late final Maybe<Res> response;
    try {
      response = await _backend._sendRequestToBackend(
        DataBusRequest(
          event: event,
          data: data,
          to: BackendType.toString(),
          from: _backend.runtimeType.toString(),
          id: generateSimpleRandomCode(),
        ),
      );
    } catch (error) {
      print('[$runtimeType | ${_backend.runtimeType}] ERROR: $error');
      response = Maybe<Res>(data: null, error: error);
    }
    return response;
  }
}
