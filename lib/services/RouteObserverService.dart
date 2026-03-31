import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

class RouteObserverService extends NavigatorObserver {
  final currRoute = ''.obs;

  void _setRoute(String? name) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      currRoute.value = name ?? '';
    });
  }

  @override
  void didPush(Route route, Route? previousRoute) => _setRoute(route.settings.name);

  @override
  void didPop(Route route, Route? previousRoute) => _setRoute(previousRoute?.settings.name);

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) => _setRoute(newRoute?.settings.name);
}
