import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'states/first/first_state.dart';
import 'states/second/second_state.dart';

class ItemsView extends StatefulWidget {
  const ItemsView({Key key}) : super(key: key);

  @override
  _ItemsViewState createState() {
    return _ItemsViewState();
  }
}

class _ItemsViewState extends State<ItemsView> {
  SecondState get secondState => Provider.of(context);
  SecondState get staticSecondState => Provider.of(context, listen: false);
  FirstState get staticFirstState => Provider.of(context, listen: false);

  final ScrollController _itemsScrollController = ScrollController();

  Widget _itemBuilder(BuildContext context, int index) {
    final Item item = staticSecondState.getItemByIndex(index);
    return ListTile(
      key: Key('${item.id}'),
      title: Text(item.title),
      subtitle: Text(item.description),
      trailing: IconButton(onPressed: () => staticSecondState.removeItem(item.id), icon: const Icon(Icons.clear), color: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Items list'),
        actions: [
          IconButton(
            onPressed: () => staticSecondState.addItem('${staticFirstState.counter + 1}th item', 'No description'),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Scrollbar(
        controller: _itemsScrollController,
        child: ListView.builder(
          controller: _itemsScrollController,
          itemBuilder: _itemBuilder,
          itemCount: secondState.items.length,
        ),
      ),
    );
  }
}
