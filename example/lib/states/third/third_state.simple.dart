import 'dart:math';

import 'package:dio/dio.dart';
import 'package:example/fps_monitor.dart';
import 'package:example/states/base_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:isolator/isolator.dart';

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
  searchEnd,
  cacheItems,
}

const DELAY_BEFORE_REQUEST = 250;
const REQUESTS_PER_TIME = 5;
const MAX_REQUESTS = 10;
const SEARCH_MULTIPLIER = 10;
const MAX_FILTER_WORDS = 15;

class ThirdStateSimple extends BaseState<ThirdEvents> {
  bool isLoading = false;
  final List<Item> _notFilteredItems = [];
  final List<Item> items = [];
  final List<double> frames = [];
  final List<double> requestDurations = [];
  final TextEditingController searchController = TextEditingController();

  Item getItemByIndex(int index) => items[index];

  void clearItems() {
    searchController.clear();
    send(ThirdEvents.clearAll);
  }

  Future<void> initState() async {
    await initBackend(createThirdState);
  }

  void _startFpsMeter() {
    FpsMonitor.instance.refreshRate = 90;
    FpsMonitor.instance.start();
  }

  void _stopFpsMeter() {
    frames.addAll(FpsMonitor.instance.stop());
    print('Frames:\n${frames.join(' ').replaceAll('.', ',')}');
    frames.clear();
  }

  Future<void> loadItems() async {
    _startFpsMeter();
    isLoading = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: DELAY_BEFORE_REQUEST));
    List<Item> mainThreadItems;
    for (int i = 0; i < MAX_REQUESTS; i++) {
      bench.startTimer('Load items in main thread');
      mainThreadItems = await makeManyRequests(REQUESTS_PER_TIME);
      final double diff = bench.endTimer('Load items in main thread');
      requestDurations.add(diff);
    }
    items.clear();
    items.addAll(mainThreadItems);
    await Future<void>.delayed(const Duration(milliseconds: DELAY_BEFORE_REQUEST));
    isLoading = false;
    notifyListeners();
    _stopFpsMeter();
    print('Load items in main thread ->' + requestDurations.join(' ').replaceAll('.', ','));
    requestDurations.clear();
  }

  Future<void> loadItemsWithComputed() async {
    _startFpsMeter();
    isLoading = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: DELAY_BEFORE_REQUEST));
    List<Item> computedItems;
    if (false) {
      for (int i = 0; i < MAX_REQUESTS; i++) {
        bench.startTimer('Load items in computed');
        computedItems = await compute<dynamic, List<Item>>(_loadItemsWithComputed, null);
        final double diff = bench.endTimer('Load items in computed');
        requestDurations.add(diff);
      }
    } else {
      bench.startTimer('Load items in computed');
      computedItems = await compute<dynamic, List<Item>>(_loadAllItemsWithComputed, null);
      final double diff = bench.endTimer('Load items in computed');
      requestDurations.add(diff);
    }
    items.clear();
    items.addAll(computedItems);
    await Future<void>.delayed(const Duration(milliseconds: DELAY_BEFORE_REQUEST));
    isLoading = false;
    notifyListeners();
    _stopFpsMeter();
    print('Load items in computed ->' + requestDurations.join(' ').replaceAll('.', ','));
    requestDurations.clear();
  }

  Future<void> loadItemsWithIsolate() async {
    _startFpsMeter();
    isLoading = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: DELAY_BEFORE_REQUEST));
    bench.startTimer('Load items in separate isolate');
    send(ThirdEvents.startLoadingItems);
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
    await Future<void>.delayed(const Duration(milliseconds: DELAY_BEFORE_REQUEST));
    isLoading = false;
    notifyListeners();
    _stopFpsMeter();
    print('Load items in isolate ->' + requestDurations.join(' ').replaceAll('.', ','));
    requestDurations.clear();
  }

  void _clearItems() {
    items.clear();
    _notFilteredItems.clear();
    notifyListeners();
  }

  void _searchInMainThread() {
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

  Future<void> _searchOnCompute() async {
    final String searchValue = searchController.text;
    if (searchValue.isEmpty && items.length != _notFilteredItems.length) {
      items.clear();
      items.addAll(_notFilteredItems);
      notifyListeners();
      return;
    }
    items.clear();
    items.addAll(await compute(filterItems, Packet2(_notFilteredItems, searchValue)));
    notifyListeners();
  }

  void cacheItems() {
    _notFilteredItems.clear();
    final List<Item> multipliedItems = [];
    for (int i = 0; i < SEARCH_MULTIPLIER; i++) {
      multipliedItems.addAll(items);
    }
    _notFilteredItems.addAll(multipliedItems);
  }

  Future<void> _setWord(String word) async {
    searchController.value = TextEditingValue(text: word);
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }

  Future<void> _testSearch() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    List<String> words = items.map((Item item) => item.profile.replaceAll('https://opencollective.com/', '')).toSet().toList();
    words = words
        .map((String word) {
          final String newWord = word.substring(0, min(word.length, 4));
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
    _stopFpsMeter();
  }

  Future<void> runSearchOnMainThread() async {
    cacheItems();
    isLoading = true;
    notifyListeners();
    searchController.addListener(_searchInMainThread);
    await _testSearch();
    send(ThirdEvents.searchEnd);
    searchController.removeListener(_searchInMainThread);
    isLoading = false;
    notifyListeners();
  }

  Future<void> runSearchWithCompute() async {
    cacheItems();
    isLoading = true;
    notifyListeners();
    searchController.addListener(_searchOnCompute);
    await _testSearch();
    searchController.removeListener(_searchOnCompute);
    isLoading = false;
    notifyListeners();
  }

  Future<void> runSearchInIsolate() async {
    send(ThirdEvents.cacheItems);
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

  void _searchInIsolate() {
    send(ThirdEvents.startSearch, searchController.text);
  }

  void _setFilteredItems(List<Item> filteredItems) {
    items.clear();
    items.addAll(filteredItems);
    notifyListeners();
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

Future<List<Item>> _loadAllItemsWithComputed([dynamic _]) async {
  List<Item> items;
  for (int i = 0; i < MAX_REQUESTS; i++) {
    items = await makeManyRequests(REQUESTS_PER_TIME);
  }
  return items;
}

Future<List<Item>> makeManyRequests(int howMuch) async {
  final List<Response<dynamic>> responses = await Future.wait(List.filled(howMuch, Dio().get<dynamic>('https://opencollective.com/webpack/members/all.json')));
  final List<Item> items = Item.fromJsonList(responses[0].data);
  return items;
}

List<Item> filterItems(Packet2<List<Item>, String> itemsAndInputValue) {
  return itemsAndInputValue.value.where((Item item) => item.profile.contains(itemsAndInputValue.value2)).toList();
}
