import 'package:adb_files/screens/window_screen.dart';
import 'package:flutter/material.dart';

import '../models/app_state_manager.dart';

class AppRouter extends RouterDelegate
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  @override
  final GlobalKey<NavigatorState> navigatorKey;
  final AppStateManager appStateManager;

  AppRouter({required this.appStateManager})
      : navigatorKey = GlobalKey<NavigatorState>() {
    appStateManager.addListener(notifyListeners);
  }

  @override
  void dispose() {
    appStateManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onPopPage: (Route route, result) {
        return _onPopPage(route, result);
      },
      pages: [WindowScreen.page()],
    );
  }

  @override
  Future<void> setNewRoutePath(configuration) async => null;

  bool _onPopPage(Route route, result) {
    if (!route.didPop(result)) return false;

    appStateManager.pop();

    return true;
  }
}
