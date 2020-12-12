import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'home_view.dart';
import 'states/first/first_state.dart';
import 'states/second/second_state.dart';

Future<void> main() async {
  final FirstState firstState = FirstState();
  final SecondState secondState = SecondState(firstState);
  await firstState.initState();
  await secondState.initState();
  runApp(MyApp(firstState, secondState));
}

class MyApp extends StatelessWidget {
  const MyApp(this.firstState, this.secondState);

  final FirstState firstState;
  final SecondState secondState;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: firstState),
        ChangeNotifierProvider.value(value: secondState),
      ],
      child: MaterialApp(
        title: 'Isolator demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const HomeView(title: 'Isolator demo'),
      ),
    );
  }
}
