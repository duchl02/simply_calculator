import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:simply_calculator/core/firebase/analytics/analytics_util.dart';
import 'package:simply_calculator/core/helper/app_log.dart';

class AppRouterObserver extends AutoRouterObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    LogX.log('${previousRoute?.settings.name} push to ${route.settings.name}');
    AnalyticsUtil.logEvent('route_push', {
      'route': route.settings.name ?? 'unknown_route',
      'previous_route': previousRoute?.settings.name ?? 'unknown_route',
    });
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    LogX.log('${previousRoute?.settings.name} pop to ${route.settings.name}');
    AnalyticsUtil.logEvent('route_pop', {
      'route': route.settings.name ?? 'unknown_route',
      'previous_route': previousRoute?.settings.name ?? 'unknown_route',
    });
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    LogX.log('${newRoute?.settings.name} replace ${oldRoute?.settings.name}');
    AnalyticsUtil.logEvent('route_replace', {
      'old_route': oldRoute?.settings.name ?? 'unknown_route',
      'new_route': newRoute?.settings.name ?? 'unknown_route',
    });
  }
}
