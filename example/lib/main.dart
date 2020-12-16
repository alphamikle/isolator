import 'package:example/navigation/route_delegate.dart';
import 'package:example/navigation/route_parser.dart';
import 'package:example/states/third/third_state.simple.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statsfl/statsfl.dart';

import 'states/base_state.dart';
import 'states/first/first_state.dart';
import 'states/second/second_state.dart';

Future<List<ChangeNotifierProvider<BaseState<dynamic>>>> _constructNotifiers([BuildContext context]) async {
  final FirstState firstState = FirstState();
  final SecondState secondState = SecondState(firstState, context);
  final ThirdStateSimple thirdStateSimple = ThirdStateSimple();
  await Future.wait([
    firstState.initState(),
    secondState.initState(),
    thirdStateSimple.initState(),
  ]);
  return <ChangeNotifierProvider<BaseState<dynamic>>>[
    ChangeNotifierProvider<FirstState>.value(value: firstState),
    ChangeNotifierProvider<SecondState>.value(value: secondState),
    ChangeNotifierProvider<ThirdStateSimple>.value(value: thirdStateSimple),
  ];
}

Future<void> main() async {
  runApp(
    StatsFl(
      width: 600,
      totalTime: 15,
      maxFps: 90,
      isEnabled: false,
      height: 50,
      sampleTime: 0.05,
      align: Alignment.bottomCenter,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (BuildContext context) => FutureBuilder<List<ChangeNotifierProvider<BaseState<dynamic>>>>(
            future: _constructNotifiers(context),
            builder: (BuildContext context, AsyncSnapshot<List<ChangeNotifierProvider<BaseState<dynamic>>>> snapshot) {
              return snapshot.data == null || snapshot.data.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : MultiProvider(
                      providers: [
                        ...snapshot.data,
                        ChangeNotifierProvider<CommentsRouteDelegate>(create: (_) => CommentsRouteDelegate()),
                      ],
                      child: Builder(
                        builder: (BuildContext context) => MaterialApp.router(
                          title: 'Isolator demo',
                          theme: ThemeData(
                            primarySwatch: Colors.blue,
                            visualDensity: VisualDensity.adaptivePlatformDensity,
                          ),
                          routeInformationParser: RouteParser(),
                          routerDelegate: Provider.of<CommentsRouteDelegate>(context),
                        ),
                      ),
                    );
            },
          ),
        ),
      ),
    );
  }
}
