import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simply_calculator/core/bloc/app_cubit/app_cubit.dart';
import 'package:simply_calculator/di/di.dart';

import 'flex_color_scheme.dart';

class AppTheme {
  static ThemeData getDarkTheme() {
    final appCubit = getIt<AppCubit>();
    return FlexThemeData.dark(
      scheme: appCubit.state.theme,
      fontFamily: appCubit.state.fontFamily,
      textTheme: getTextTheme(),
      subThemesData: const FlexSubThemesData(
        interactionEffects: true,
        tintedDisabledControls: true,
        useM2StyleDividerInM3: true,
        inputDecoratorIsFilled: true,
        inputDecoratorBorderType: FlexInputBorderType.outline,
        alignedDropdown: true,
        navigationRailUseIndicator: true,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
    );
  }

  static ThemeData getLightTheme() {
    final appCubit = getIt<AppCubit>();
    return FlexThemeData.light(
      scheme: appCubit.state.theme,
      fontFamily: appCubit.state.fontFamily,
      textTheme: getTextTheme(),
      subThemesData: const FlexSubThemesData(
        interactionEffects: true,
        tintedDisabledControls: true,
        useM2StyleDividerInM3: true,
        inputDecoratorIsFilled: true,
        inputDecoratorBorderType: FlexInputBorderType.outline,
        alignedDropdown: true,
        navigationRailUseIndicator: true,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
    );
  }

  static TextTheme getTextTheme() {
    final fontFamily = getIt<AppCubit>().state.fontFamily;
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 57,
        fontWeight: FontWeight.normal,
      ),
      displayMedium: TextStyle(fontFamily: fontFamily, fontSize: 45),
      displaySmall: TextStyle(fontFamily: fontFamily, fontSize: 36),

      headlineLarge: TextStyle(fontFamily: fontFamily, fontSize: 32),
      headlineMedium: TextStyle(fontFamily: fontFamily, fontSize: 28),
      headlineSmall: TextStyle(fontFamily: fontFamily, fontSize: 24),

      titleLarge: TextStyle(fontFamily: fontFamily, fontSize: 22),
      titleMedium: TextStyle(fontFamily: fontFamily, fontSize: 16),
      titleSmall: TextStyle(fontFamily: fontFamily, fontSize: 14),

      labelLarge: TextStyle(fontFamily: fontFamily, fontSize: 14),
      labelMedium: TextStyle(fontFamily: fontFamily, fontSize: 12),
      labelSmall: TextStyle(fontFamily: fontFamily, fontSize: 11),

      bodyLarge: TextStyle(fontFamily: fontFamily, fontSize: 16),
      bodyMedium: TextStyle(fontFamily: fontFamily, fontSize: 14),
      bodySmall: TextStyle(fontFamily: fontFamily, fontSize: 12),
    );
  }
}
