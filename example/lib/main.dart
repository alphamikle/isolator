import 'package:example/navigation/route_delegate.dart';
import 'package:example/navigation/route_parser.dart';
import 'package:example/states/third/third_state.simple.dart';
import 'package:flutter/material.dart';
import 'package:isolator/isolator.dart';
import 'package:provider/provider.dart';
import 'package:statsfl/statsfl.dart';

import 'states/base_state.dart';
import 'states/first/first_state.dart';
import 'states/second/second_state.dart';

Future<List<ChangeNotifierProvider<BaseState<dynamic>>>> _constructNotifiers([ScaffoldState state]) async {
  final FirstState firstState = FirstState();
  final SecondState secondState = SecondState(firstState, state);
  final ThirdStateSimple thirdStateSimple = ThirdStateSimple();
  await firstState.initState();
  await secondState.initState();
  await thirdStateSimple.initState();
  return <ChangeNotifierProvider<BaseState<dynamic>>>[
    ChangeNotifierProvider<FirstState>.value(value: firstState),
    ChangeNotifierProvider<SecondState>.value(value: secondState),
    ChangeNotifierProvider<ThirdStateSimple>.value(value: thirdStateSimple),
  ];
}

Future<void> onBackendError(dynamic error) async {
  print('Backend error observer was called with error $error');
}

Future<void> onDataLoadFromBackend(Message<dynamic, dynamic> message) async {
  print('Got a message from backend in observer $message');
}

Future<void> main() async {
  IsolatorConfig.setTransferTimeLogging(true);
  IsolatorConfig.setLogging(true);
  IsolatorConfig.setBackendErrorsObservers([onBackendError]);
  IsolatorConfig.setFrontendObservers([onDataLoadFromBackend]);
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

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: _scaffoldKey,
        body: Builder(
          builder: (BuildContext context) => FutureBuilder<List<ChangeNotifierProvider<BaseState<dynamic>>>>(
            future: _constructNotifiers(_scaffoldKey.currentState),
            builder: (BuildContext context, AsyncSnapshot<List<ChangeNotifierProvider<BaseState<dynamic>>>> snapshot) {
              final List<ChangeNotifierProvider<BaseState<dynamic>>> data = snapshot.data;
              print('Data from notifiers "$data"');
              return data == null || data.isEmpty
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
