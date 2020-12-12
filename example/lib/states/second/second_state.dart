import 'package:flutter/widgets.dart';
import 'package:isolator/isolator.dart';

import '../first/first_state.dart';
import 'second_backend.dart';

enum SecondEvents {
  addItem,
  removeItem,
}

class Item {
  int id;
  String title;
  String description;
}

class SecondState with ChangeNotifier, BackendMixin<SecondEvents> {
  SecondState(this.firstState);

  final FirstState firstState;

  final List<Item> items = [];

  bool isTransferInProcess = false;

  Item getItemByIndex(int index) => items[index];

  void addItem(String title, String description) {
    firstState.onEvent(FirstEvents.increment, () => _addItem(title, description));
    firstState.increment();
  }

  void _addItem(String title, String description) {
    send(SecondEvents.addItem, Packet2(title, description));
  }

  void removeItem(int itemId) {
    send(SecondEvents.removeItem, itemId);
  }

  Future<void> initState() async {
    await initBackend(createSecondBackend);
  }

  void _refreshItems(List<Item> items) {
    this.items.clear();
    this.items.addAll(items);
  }

  @override
  Map<SecondEvents, Function> get tasks => {
        SecondEvents.addItem: _refreshItems,
        SecondEvents.removeItem: _refreshItems,
      };

  @override
  void onBackendResponse() {
    notifyListeners();
  }
}
