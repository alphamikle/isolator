import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class RouteParser extends RouteInformationParser<Object> {
  @override
  Future<Object> parseRouteInformation(RouteInformation routeInformation) {
    print('ROUTE INFORMATION -> ${routeInformation.location}, ${routeInformation.state}');
    return SynchronousFuture<String>('LALALA');
  }
}
