import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:simply_calculator/constants/app_const.dart';
import 'package:simply_calculator/core/style/flex_theme/flex_scheme.dart';
import 'package:simply_calculator/domain/repositories/app_repository.dart';
import 'package:simply_calculator/i18n/strings.g.dart';
import 'package:simply_calculator/domain/entities/favorite_calc_item.dart';

part 'app_state.dart';

@singleton
class AppCubit extends Cubit<AppState> {
  AppCubit({required this.appRepository}) : super(const AppState());

  final AppRepository appRepository;

  void initial() {
    _initLanguage();
    _initFontFamily();
    _initTheme();
    _initDarkMode();
    _initFavorites();
    _initDefaultCalculator();
  }

  void setLanguage(String language) {
    final appLocale = AppLocale.values.firstWhere(
      (element) => element.languageCode == language,
      orElse: () => AppLocale.en,
    );
    LocaleSettings.setLocale(appLocale);
    appRepository.setLanguage(appLocale.languageCode);
    emit(state.copyWith(language: appLocale.languageCode));
  }

  void setTheme(FlexScheme theme) {
    appRepository.setTheme(theme.name);
    emit(state.copyWith(theme: theme));
  }

  void setDarkMode(bool isDarkMode) {
    appRepository.setDarkMode(isDarkMode);
    emit(state.copyWith(isDarkMode: isDarkMode));
  }

  void setFontFamily(String fontFamily) {
    appRepository.setFontFamily(fontFamily);
    emit(state.copyWith(fontFamily: fontFamily));
  }

  void _initDarkMode() {
    final isDarkModeLocal = appRepository.getDarkMode();
    bool isDarkMode = false;
    ThemeMode themeMode = ThemeMode.system;
    if (isDarkModeLocal == null) {
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      isDarkMode = brightness == Brightness.dark;
      themeMode =
          isDarkMode
              ? ThemeMode.dark
              : WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                  Brightness.light
              ? ThemeMode.light
              : ThemeMode.system;
    } else {
      isDarkMode = isDarkModeLocal;
    }

    emit(state.copyWith(isDarkMode: isDarkMode, themeMode: themeMode));
  }

  void setThemeMode(ThemeMode themeMode) {
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final isDarkMode =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);
    emit(state.copyWith(isDarkMode: isDarkMode, themeMode: themeMode));
  }

  Future<void> _initLanguage() async {
    final language = appRepository.getLanguage();
    final appLocale = AppLocale.values.firstWhere(
      (element) => element.languageCode == language,
      orElse: () => AppLocale.en,
    );
    await LocaleSettings.setLocale(appLocale);
    emit(state.copyWith(language: appLocale.languageCode));
  }

  void _initTheme() {
    final String? themeLocal = appRepository.getTheme();
    final FlexScheme theme = FlexScheme.values.firstWhere(
      (e) => e.name == themeLocal,
      orElse: () => FlexScheme.gold,
    );
    emit(state.copyWith(theme: theme));
  }

  void _initFontFamily() {
    final fontFamily = appRepository.getFontFamily();
    emit(state.copyWith(fontFamily: fontFamily));
  }

  void _initFavorites() {
    final favorites = appRepository.getFavoriteCalculator();
    emit(state.copyWith(favorites: favorites));
  }

  void toggleFavorite(FavoriteCalcItem item) {
    final currentFavorites = List<FavoriteCalcItem>.from(state.favorites);
    final index = currentFavorites.indexWhere(
      (fav) => fav.routeName == item.routeName,
    );

    if (index >= 0) {
      currentFavorites.removeAt(index);
    } else {
      currentFavorites.add(item);
    }
    appRepository.setFavoriteCalculator(currentFavorites);
    emit(state.copyWith(favorites: currentFavorites));
  }

  bool isFavorite(String routeName) {
    return state.favorites.any((fav) => fav.routeName == routeName);
  }

  void _initDefaultCalculator() {
    final defaultCalculator = appRepository.getDefaultCalculator();
    emit(state.copyWith(defaultCalculator: defaultCalculator));
  }
  void setDefaultCalculator(String routeName) {
    emit(state.copyWith(defaultCalculator: routeName));
    appRepository.setDefaultCalculator(routeName);
  }

  static String getLanguageName() {
    final language = LocaleSettings.currentLocale.languageCode;
    for (final lang in AppConst.languages) {
      if (lang['code'] == language) {
        return lang['name'] ?? '';
      }
    }
    return AppLocale.en.name;
  }
}
