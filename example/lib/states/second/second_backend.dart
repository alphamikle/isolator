import 'dart:isolate';

import 'package:isolator/isolator.dart';

import 'second_state.dart';

void createSecondBackend(BackendArgument<void> argument) {
  SecondBackend(argument.toFrontend);
}

class SecondBackend extends Backend<SecondEvents> {
  SecondBackend(SendPort sendPortToFront) : super(sendPortToFront);

  final List<Item> _items = [];

  Item _createItem(int itemId) {
    final Item item = Item();
    item.id = itemId;
    item.title = 'Item title — $itemId';
    item.description = 'Item description — $itemId';
    return item;
  }

  void _addItem(Packet2<String, String> packet) {
    final Item item = _createItem(_items.length);
    item.title = packet.value;
    item.description = packet.value2;
    _items.insert(0, item);
    send(SecondEvents.addItem, _items);
  }

  void _removeItem(int itemId) {
    _items.removeWhere((Item item) => item.id == itemId);
    send(SecondEvents.removeItem, _items);
  }

  @override
  Map<SecondEvents, Function> get operations => {
        SecondEvents.addItem: _addItem,
        SecondEvents.removeItem: _removeItem,
      };
}
