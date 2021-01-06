import 'package:example/states/third/model/item.dart';
import 'package:example/states/third/third_state.simple.dart';
import 'package:isolator/isolator.dart';

void createThirdState(BackendArgument<void> argument) {
  ThirdBackend(argument);
}

class ThirdBackend extends Backend<ThirdEvents, void> {
  ThirdBackend(BackendArgument<void> argument) : super(argument);

  final List<Item> _notFilteredItems = [];
  final List<Item> _items = [];

  void _clearAll() {
    _items.clear();
    send(ThirdEvents.clearAll);
  }

  Future<void> _loadingItems() async {
    _items.clear();
    for (int i = 0; i < MAX_REQUESTS; i++) {
      _items.addAll(await makeManyRequests(REQUESTS_PER_TIME));
      if (i < (MAX_REQUESTS - 1)) {
        send(ThirdEvents.loadingItems);
      } else {
        send(ThirdEvents.endLoadingItems, _items);
      }
    }
  }

  void _cacheItems() {
    _notFilteredItems.clear();
    final List<Item> multipliedItems = [];
    for (int i = 0; i < SEARCH_MULTIPLIER; i++) {
      multipliedItems.addAll(_items);
    }
    _notFilteredItems.addAll(multipliedItems);
    send(ThirdEvents.cacheItems);
  }

  void _filterItems(String searchValue) {
    if (searchValue.isEmpty) {
      _items.clear();
      _items.addAll(_notFilteredItems);
      send(ThirdEvents.setFilteredItems, _items);
      return;
    }
    final List<Item> filteredItems = filterItems(Packet2(_notFilteredItems, searchValue));
    _items.clear();
    _items.addAll(filteredItems);
    send(ThirdEvents.setFilteredItems, _items);
  }

  @override
  Map<ThirdEvents, Function> get operations => {
        ThirdEvents.clearAll: _clearAll,
        ThirdEvents.startLoadingItems: _loadingItems,
        ThirdEvents.startSearch: _filterItems,
        ThirdEvents.cacheItems: _cacheItems,
      };
}
