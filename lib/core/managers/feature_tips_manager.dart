import 'dart:math';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simply_calculator/core/bloc/app_cubit/app_cubit.dart';
import 'package:simply_calculator/di/di.dart';
import 'package:simply_calculator/i18n/strings.g.dart';
import 'package:simply_calculator/router/app_router.gr.dart';
import 'package:simply_calculator/screen/widgets/dialog/app_dialog.dart';

class FeatureTipsManager {
  static const String _seenTipsKey = 'seen_feature_tips';
  static const String _disabledTipsKey = 'disabled_feature_tips';
  static const String _lastSkipTimestampKey = 'last_skip_timestamp';
  static const int _maxTipsPerSession = 1;
  static const int _skipDurationDays = 7;
  static int _tipsShownThisSession = 0;

  // List of all available feature tips
  static final List<FeatureTip> _allTips = [
    FeatureTip(
      title: t.personalize_your_app,
      message: t.tip_theme_customization,
      route: ThemeSettingsRoute.name,
    ),
    FeatureTip(
      title: t.did_you_know,
      message: t.tip_start_open,
      route: SettingsRoute.name,
    ),
    FeatureTip(
      title: t.did_you_know,
      message: t.tip_unit_converter,
      route: UnitConverterRoute.name,
    ),
    FeatureTip(
      title: t.did_you_know,
      message: t.tip_discount_calculator,
      route: DiscountCalculatorRoute.name,
    ),
    // FeatureTip(
    //   title: t.did_you_know,
    //   message: t.tip_tip_calculator,
    //   route: TipCalculatorRoute.name,
    // ),
    // FeatureTip(
    //   title: t.did_you_know,
    //   message: t.tip_bmi_calculator,
    //   route: BmiCalculatorRoute.name,
    // ),
    // FeatureTip(
    //   title: t.did_you_know,
    //   message: t.tip_date_calculator,
    //   route: DateCalculatorRoute.name,
    // ),
    FeatureTip(
      title: t.never_lose_a_calculation,
      message: t.tip_history_feature,
      route: CalcHistoryRoute.name,
    ),
  ];

  // Check if tips are enabled
  static Future<bool> areTipsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_disabledTipsKey) ?? false);
  }

  // Enable or disable tips
  static Future<void> setTipsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_disabledTipsKey, !enabled);
  }

  // Get list of seen tip IDs
  static Future<List<String>> _getSeenTips() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_seenTipsKey) ?? [];
  }

  // Mark a tip as seen
  static Future<void> _markTipAsSeen(String tipId) async {
    final prefs = await SharedPreferences.getInstance();
    final seenTips = await _getSeenTips();
    if (!seenTips.contains(tipId)) {
      seenTips.add(tipId);
      await prefs.setStringList(_seenTipsKey, seenTips);
    }
  }

  // Reset all seen tips
  static Future<void> resetSeenTips() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_seenTipsKey, []);
  }

  // Check if we should show a tip now
  static Future<bool> shouldShowTip() async {
    // First check if we've already shown max tips this session
    if (_tipsShownThisSession >= _maxTipsPerSession) {
      return false;
    }

    // Check if tips are enabled at all
    final tipsEnabled = await areTipsEnabled();
    if (!tipsEnabled) {
      return false;
    }

    // Check if we're in a skip period
    final prefs = await SharedPreferences.getInstance();
    final lastSkipTimestamp = prefs.getInt(_lastSkipTimestampKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final skipDurationMs =
        _skipDurationDays * 24 * 60 * 60 * 1000; // 7 days in ms

    if (lastSkipTimestamp > 0 && now - lastSkipTimestamp < skipDurationMs) {
      // We're still in the skip period
      return false;
    }

    // Only show tips sometimes (50% chance)
    final random = Random();
    return random.nextDouble() < 0.5;
  }

  // Show a random tip dialog if appropriate
  static Future<void> maybeShowRandomTip(BuildContext context) async {
    final firstTimeOpenApp = getIt<AppCubit>().state.isFirstOpenApp;

    if (firstTimeOpenApp) {
      await showTipDialog(context, _allTips.first);
      return;
    } else {
      if (!await shouldShowTip()) {
        return;
      }

      final tip = await getRandomUnseenTip();
      if (tip != null) {
        _tipsShownThisSession++;
      }
    }
  }

  // Get a random unseen tip
  static Future<FeatureTip?> getRandomUnseenTip() async {
    final seenTips = await _getSeenTips();

    // Find the first tip in the ordered list that hasn't been seen yet
    for (final tip in _allTips) {
      if (!seenTips.contains(tip.route)) {
        return tip;
      }
    }

    // All tips have been seen
    return null;
  }

  // Show the tip dialog
  static Future<void> showTipDialog(
    BuildContext context,
    FeatureTip tip,
  ) async {
    await AppDialog.show(
      context: context,
      title: tip.title,
      content: tip.message,
      leftButtonText: t.dismiss, // Update the text to reflect the skip duration
      rightButtonText: t.try_it,
      isDismissible: true,
      onLeftButton: () {
        Navigator.pop(context);
        _skipTipsForOneWeek(); // Add this new method call
      },
      onRightButton: () {
        Navigator.pop(context);
        if (tip.route.isNotEmpty) {
          context.router.push(NamedRoute(tip.route));
        }
        _markTipAsSeen(tip.route);
      },
    );

    // Only mark as seen if they try it, not if they skip
    // Remove this line: await _markTipAsSeen(tip.route);
  }

  // Mark a feature as used (so its tip won't show)
  static Future<void> markFeatureAsUsed(String featureId) async {
    await _markTipAsSeen(featureId);
  }

  // Reset session counter when app starts
  static void resetSessionCounter() {
    _tipsShownThisSession = 0;
  }

  // Add this new method to handle skipping tips
  static Future<void> _skipTipsForOneWeek() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt(_lastSkipTimestampKey, now);
  }
}

// Model class for feature tips
class FeatureTip {
  final String title;
  final String message;
  final String route;

  FeatureTip({required this.title, required this.message, this.route = ''});
}
