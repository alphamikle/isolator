import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'items_view.dart';
import 'states/first/first_state.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key key, this.title}) : super(key: key);

  final String title;
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  FirstState get firstState => Provider.of(context);

  void _openItemsList() {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ItemsView()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: firstState.isComputing
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    )
                  : Text(
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
            MaterialButton(onPressed: _openItemsList, child: const Text('Open items')),
          ],
        ),
      ),
    );
  }
}
