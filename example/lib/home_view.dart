import 'package:anitex/anitex.dart';
import 'package:example/navigation/route_delegate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'states/first/first_state.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  FirstState get firstState => Provider.of(context);
  FirstState get staticFirstState => Provider.of(context, listen: false);
  CommentsRouteDelegate get commentsRouter => Provider.of(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Isolator example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: AnimatedText(
                firstState.counter.toString(),
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(icon: const Icon(Icons.add), onPressed: firstState.increment, color: Colors.blue),
                IconButton(icon: const Icon(Icons.remove), onPressed: firstState.decrement, color: Colors.red),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MaterialButton(
                  onPressed: () => staticFirstState.increment(50),
                  highlightColor: Colors.transparent,
                  splashColor: Colors.blue.withOpacity(0.25),
                  child: const Text(
                    '+ 50',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                MaterialButton(
                  onPressed: () => staticFirstState.decrement(50),
                  highlightColor: Colors.transparent,
                  splashColor: Colors.red.withOpacity(0.25),
                  child: const Text(
                    '- 50',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MaterialButton(
                  onPressed: () => staticFirstState.increment(250),
                  highlightColor: Colors.transparent,
                  splashColor: Colors.blue.withOpacity(0.25),
                  child: const Text(
                    '+ 250',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                MaterialButton(
                  onPressed: () => staticFirstState.decrement(250),
                  highlightColor: Colors.transparent,
                  splashColor: Colors.red.withOpacity(0.25),
                  child: const Text(
                    '- 250',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
            MaterialButton(onPressed: commentsRouter.openComments, child: const Text('Open comments')),
            MaterialButton(onPressed: commentsRouter.openItems, child: const Text('Open items')),
          ],
        ),
      ),
    );
  }
}
