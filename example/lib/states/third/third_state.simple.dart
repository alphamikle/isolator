import 'dart:math';

import 'package:dio/dio.dart';
import 'package:example/fps_monitor.dart';
import 'package:example/states/base_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:isolator/isolator.dart';
import 'package:pedantic/pedantic.dart';
import 'package:string_similarity/string_similarity.dart';

import '../../benchmark.dart';
import 'model/item.dart';
import 'third_backend.dart';

enum ThirdEvents {
  loadAll,
  clearAll,
  startLoadingItems,
  loadingItems,
  endLoadingItems,
  startSearch,
  setFilteredItems,
  cacheItems,
}

const DELAY_BEFORE_REQUEST = 250;
const REQUESTS_PER_TIME = 5;
const MAX_REQUESTS = 10;
const SEARCH_MULTIPLIER = 10;
const MAX_FILTER_WORDS = 3;
const MIN_SIMILARITY_VALUE = 0.3;
const SEARCH_WORD_LENGTH = 3;
const DELAY_BETWEEN_INPUTS = 600;
const USE_SIMILARITY = true;

class ThirdStateSimple extends BaseState<ThirdEvents> {
  bool isLoading = false;
  final List<Item> _notFilteredItems = [];
  final List<Item> items = [];
  final List<double> frames = [];
  final List<double> requestDurations = [];
  final TextEditingController searchController = TextEditingController();
  bool canPlaceNextLetter = true;
  bool isSearching = false;

  Item getItemByIndex(int index) => items[index];

  void clearItems() {
    searchController.clear();
    send<void>(ThirdEvents.clearAll);
  }

  Future<void> initState() async {
    await initBackend(createThirdState);
  }

  void cacheItems() {
    _notFilteredItems.clear();
    final List<Item> multipliedItems = [];
    for (int i = 0; i < SEARCH_MULTIPLIER; i++) {
      multipliedItems.addAll(items);
    }
    _notFilteredItems.addAll(multipliedItems);
  }

  /// Loading items ////////////////////////////////

  Future<void> loadItemsOnMainThread() async {
    _startFpsMeter();
    isLoading = true;
    notifyListeners();
    await wait(DELAY_BEFORE_REQUEST);
    late List<Item> mainThreadItems;
    for (int i = 0; i < MAX_REQUESTS; i++) {
      bench.startTimer('Load items in main thread');
      mainThreadItems = await makeManyRequests(REQUESTS_PER_TIME);
      final double diff = bench.endTimer('Load items in main thread');
      requestDurations.add(diff);
    }
    items.clear();
    items.addAll(mainThreadItems);
    await wait(DELAY_BEFORE_REQUEST);
    isLoading = false;
    notifyListeners();
    unawaited(_stopFpsMeter());
    print('Load items in main thread ->' + requestDurations.join(' ').replaceAll('.', ','));
    requestDurations.clear();
  }

  Future<void> loadItemsWithComputed() async {
    _startFpsMeter();
    isLoading = true;
    notifyListeners();
    await wait(DELAY_BEFORE_REQUEST);
    late List<Item> computedItems;
    for (int i = 0; i < MAX_REQUESTS; i++) {
      bench.startTimer('Load items in computed');
      computedItems = await compute<dynamic, List<Item>>(_loadItemsWithComputed, null);
      final double diff = bench.endTimer('Load items in computed');
      requestDurations.add(diff);
    }
    // if (true) {
    // } else {
    //   bench.startTimer('Load items in computed');
    //   computedItems = await compute<dynamic, List<Item>>(_loadAllItemsWithComputed, null);
    //   final double diff = bench.endTimer('Load items in computed');
    //   requestDurations.add(diff);
    // }
    items.clear();
    items.addAll(computedItems);
    await wait(DELAY_BEFORE_REQUEST);
    isLoading = false;
    notifyListeners();
    unawaited(_stopFpsMeter());
    print('Load items in computed ->' + requestDurations.join(' ').replaceAll('.', ','));
    requestDurations.clear();
  }

  Future<void> loadItemsWithIsolate() async {
    _startFpsMeter();
    isLoading = true;
    notifyListeners();
    await wait(DELAY_BEFORE_REQUEST);
    bench.startTimer('Load items in separate isolate');
    send<void>(ThirdEvents.startLoadingItems);
  }

  /// Search items ////////////////////////////////

  Future<void> runSearchOnMainThread() async {
    cacheItems();
    isLoading = true;
    notifyListeners();
    searchController.addListener(_searchOnMainThread);
    await _testSearch();
    searchController.removeListener(_searchOnMainThread);
    isLoading = false;
    notifyListeners();
  }

  Future<void> runSearchWithCompute() async {
    cacheItems();
    isLoading = true;
    notifyListeners();
    searchController.addListener(_searchWithCompute);
    await _testSearch();
    searchController.removeListener(_searchWithCompute);
    isLoading = false;
    notifyListeners();
  }

  Future<void> runSearchInIsolate() async {
    send<void>(ThirdEvents.cacheItems);
  }

  void _middleLoadingEvent() {
    final double time = bench.endTimer('Load items in separate isolate');
    requestDurations.add(time);
    bench.startTimer('Load items in separate isolate');
  }

  Future<void> _endLoadingEvents(List<Item> items) async {
    this.items.clear();
    this.items.addAll(items);
    final double time = bench.endTimer('Load items in separate isolate');
    requestDurations.add(time);
    await wait(DELAY_BEFORE_REQUEST);
    isLoading = false;
    notifyListeners();
    unawaited(_stopFpsMeter());
    print('Load items in isolate ->' + requestDurations.join(' ').replaceAll('.', ','));
    requestDurations.clear();
  }

  Future<void> _searchWithCompute() async {
    canPlaceNextLetter = false;
    isSearching = true;
    notifyListeners();
    final String searchValue = searchController.text;
    if (searchValue.isEmpty && items.length != _notFilteredItems.length) {
      items.clear();
      items.addAll(_notFilteredItems);
      isSearching = false;
      notifyListeners();
      await wait(DELAY_BETWEEN_INPUTS);
      canPlaceNextLetter = true;
      return;
    }
    final List<Item> filteredItems = await compute(filterItems, Packet2(_notFilteredItems, searchValue));
    isSearching = false;
    notifyListeners();
    await wait(DELAY_BETWEEN_INPUTS);
    items.clear();
    items.addAll(filteredItems);
    notifyListeners();
    canPlaceNextLetter = true;
  }

  void _searchOnMainThread() {
    final String searchValue = searchController.text;
    if (searchValue.isEmpty && items.length != _notFilteredItems.length) {
      items.clear();
      items.addAll(_notFilteredItems);
      notifyListeners();
      return;
    }
    items.clear();
    items.addAll(filterItems(Packet2(_notFilteredItems, searchValue)));
    notifyListeners();
  }

  Future<void> _startSearchOnIsolate() async {
    isLoading = true;
    notifyListeners();
    searchController.addListener(_searchInIsolate);
    await _testSearch();
    searchController.removeListener(_searchInIsolate);
    isLoading = false;
    notifyListeners();
  }

  Future<void> _setWord(String word) async {
    if (!canPlaceNextLetter) {
      await wait(DELAY_BETWEEN_INPUTS);
      await _setWord(word);
    } else {
      searchController.value = TextEditingValue(text: word);
      await wait(DELAY_BETWEEN_INPUTS);
    }
  }

  Future<void> _testSearch() async {
    List<String> words = items.map((Item item) => item.profile.replaceAll('https://opencollective.com/', '')).toSet().toList();
    words = words
        .map((String word) {
          final String newWord = word.substring(0, min(word.length, SEARCH_WORD_LENGTH));
          return newWord;
        })
        .toSet()
        .take(MAX_FILTER_WORDS)
        .toList();

    _startFpsMeter();
    for (String word in words) {
      final List<String> letters = word.split('');
      String search = '';
      for (String letter in letters) {
        search += letter;
        await _setWord(search);
      }
      while (search.isNotEmpty) {
        search = search.substring(0, search.length - 1);
        await _setWord(search);
      }
    }
    unawaited(_stopFpsMeter());
  }

  void _searchInIsolate() {
    canPlaceNextLetter = false;
    isSearching = true;
    notifyListeners();
    send(ThirdEvents.startSearch, searchController.text);
  }

  Future<void> _setFilteredItems(List<Item> filteredItems) async {
    isSearching = false;
    notifyListeners();
    await wait(DELAY_BETWEEN_INPUTS);
    items.clear();
    items.addAll(filteredItems);
    notifyListeners();
    canPlaceNextLetter = true;
  }

  void _clearItems() {
    items.clear();
    _notFilteredItems.clear();
    notifyListeners();
  }

  void _startFpsMeter() {
    FpsMonitor.instance.refreshRate = 90;
    FpsMonitor.instance.start();
  }

  Future<void> _stopFpsMeter() async {
    frames.addAll(FpsMonitor.instance.stop());
    final String framesData = frames.join('\n').replaceAll('.', ',');
    await Clipboard.setData(ClipboardData(text: framesData));
    frames.clear();
  }

  @override
  Map<ThirdEvents, Function> get tasks => {
        ThirdEvents.clearAll: _clearItems,
        ThirdEvents.loadingItems: _middleLoadingEvent,
        ThirdEvents.endLoadingItems: _endLoadingEvents,
        ThirdEvents.setFilteredItems: _setFilteredItems,
        ThirdEvents.cacheItems: _startSearchOnIsolate,
      };
}

Future<List<Item>> _loadItemsWithComputed([dynamic _]) async {
  return makeManyRequests(5);
}

// Future<List<Item>> _loadAllItemsWithComputed([dynamic _]) async {
//   late List<Item> items;
//   for (int i = 0; i < MAX_REQUESTS; i++) {
//     items = await makeManyRequests(REQUESTS_PER_TIME);
//   }
//   return items;
// }

Future<List<Item>> makeManyRequests(int howMuch) async {
  final List<Response<dynamic>> responses =
      await Future.wait(List.filled(howMuch, Dio().get<dynamic>('https://opencollective.com/webpack/members/all.json')));
  final List<Item> items = Item.fromJsonList(responses[0].data);
  return items;
}

bool isStringsSimilar(String first, String second) {
  return max(StringSimilarity.compareTwoStrings(first, second), StringSimilarity.compareTwoStrings(second, first)) >= MIN_SIMILARITY_VALUE;
}

List<Item> filterItems(Packet2<List<Item>, String> itemsAndInputValue) {
  return itemsAndInputValue.value.where((Item item) {
    return item.profile.contains(itemsAndInputValue.value2) || (USE_SIMILARITY && isStringsSimilar(item.profile, itemsAndInputValue.value2));
  }).toList();
}

Future<void> wait(int milliseconds) async {
  await Future<void>.delayed(Duration(milliseconds: milliseconds));
}
