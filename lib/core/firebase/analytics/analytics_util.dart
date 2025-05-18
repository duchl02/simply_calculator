import 'package:firebase_analytics/firebase_analytics.dart';

part 'event_key_const.dart';

class AnalyticsUtil {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  static void logEvent(
    String eventName, [
    Map<String, Object>? params = const {},
  ]) {
    analytics.logEvent(name: eventName, parameters: params);
  }

  static void logScreen({
    required String screenName,
    Map<String, dynamic>? params,
  }) {
    logEvent('screen_view', {'screen_name': screenName, ...?params});
  }
}
