part of 'backend.dart';

abstract class InteractorOf<BackendType extends Backend> {
  InteractorOf(this._backend) : assert('$BackendType' != 'Backend');

  final Backend _backend;

  @protected
  Future<Maybe<Res>> run<Event, Req extends Object?, Res extends Object?>(
      {required Event event, Req? data}) async {
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
      print('Interactor error: $error');
      response = Maybe<Res>(data: null, error: error);
    }
    return response;
  }
}
