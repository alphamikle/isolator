import 'package:example/comments_view.dart';
import 'package:example/home_view.dart';
import 'package:example/items_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CommentsRouteDelegate extends RouterDelegate<dynamic> with ChangeNotifier, PopNavigatorRouterDelegateMixin<dynamic> {
  CommentsRouteDelegate() : navigatorKey = GlobalKey();

  bool isOnCommentsPage = false;
  bool isOnItemsPage = false;

  @override
  final GlobalKey<NavigatorState> navigatorKey;

  void openComments() {
    isOnCommentsPage = true;
    notifyListeners();
  }

  void openItems() {
    isOnItemsPage = true;
    notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        const MaterialPage<void>(
          key: ValueKey('HomeView'),
          child: HomeView(),
        ),
        if (isOnCommentsPage) const CommentsPage(),
        if (isOnItemsPage) const ItemsPage(),
      ],
      onPopPage: _onPop,
    );
  }

  bool _onPop(Route<dynamic> route, dynamic result) {
    if (!route.didPop(result)) {
      return false;
    }
    isOnCommentsPage = false;
    isOnItemsPage = false;
    notifyListeners();
    return true;
  }

  @override
  Future<void> setNewRoutePath(dynamic configuration) {
    print('NEW ROUTE CONFIGURATION "$configuration"');
    return SynchronousFuture(null);
  }
}

class CommentsPage extends Page<dynamic> {
  const CommentsPage() : super(key: const ValueKey('CommentsView'));

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute<dynamic>(
      settings: this,
      builder: (_) => const CommentsView(),
    );
  }
}

class ItemsPage extends Page<dynamic> {
  const ItemsPage() : super(key: const ValueKey('ItemsView'));

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute<dynamic>(
      settings: this,
      builder: (_) => const ItemsView(),
    );
  }
}
