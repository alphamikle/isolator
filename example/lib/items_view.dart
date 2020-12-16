import 'package:cached_network_image/cached_network_image.dart';
import 'package:example/states/third/model/item.dart';
import 'package:example/states/third/third_state.simple.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ItemsView extends StatefulWidget {
  const ItemsView({Key key}) : super(key: key);

  @override
  _ItemsViewState createState() {
    return _ItemsViewState();
  }
}

class _ItemsViewState extends State<ItemsView> {
  ThirdStateSimple get thirdState => Provider.of(context);
  ThirdStateSimple get staticThirdState => Provider.of(context, listen: false);

  final ScrollController _itemsScrollController = ScrollController();
  TextEditingController get _searchController => staticThirdState.searchController;

  Widget _itemBuilder(BuildContext context, int index) {
    final Item item = staticThirdState.getItemByIndex(index);
    return ListTile(
      key: Key('${item.id}'),
      title: Text(item.profile),
      subtitle: Text(item.createdAt.toIso8601String()),
      leading: CachedNetworkImage(imageUrl: item.imageUrl, height: 56, width: 56),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text('View'),
            const SizedBox(width: 10),
            if (thirdState.isLoading)
              const SizedBox(
                height: 30,
                width: 30,
                child: Center(
                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white)),
                ),
              ),
          ],
        ),
        actions: [
          Tooltip(
            message: 'Clear all items',
            child: IconButton(
              onPressed: thirdState.clearItems,
              icon: const Icon(Icons.clear_all),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            children: [
              Tooltip(
                message: 'Load all items in main isolate',
                child: IconButton(
                  onPressed: thirdState.loadItems,
                  icon: const Icon(Icons.filter_1),
                ),
              ),
              Tooltip(
                message: 'Load all items in compute',
                child: IconButton(
                  onPressed: thirdState.loadItemsWithComputed,
                  icon: const Icon(Icons.filter_2),
                ),
              ),
              Tooltip(
                message: 'Load all items in isolate',
                child: IconButton(
                  onPressed: thirdState.loadItemsWithIsolate,
                  icon: const Icon(Icons.filter_3),
                ),
              ),
              Tooltip(
                message: 'Search on main thread',
                child: IconButton(
                  onPressed: staticThirdState.runSearchOnMainThread,
                  icon: const Icon(Icons.filter_4),
                ),
              ),
              Tooltip(
                message: 'Search in compute func',
                child: IconButton(
                  onPressed: staticThirdState.runSearchWithCompute,
                  icon: const Icon(Icons.filter_5),
                ),
              ),
              Tooltip(
                message: 'Search in isolate',
                child: IconButton(
                  onPressed: staticThirdState.runSearchInIsolate,
                  icon: const Icon(Icons.filter_6),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Filter items',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: Scrollbar(
              controller: _itemsScrollController,
              child: ListView.builder(
                controller: _itemsScrollController,
                itemBuilder: _itemBuilder,
                itemCount: thirdState.items.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
