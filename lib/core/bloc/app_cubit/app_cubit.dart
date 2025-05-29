import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:simply_calculator/core/style/flex_theme/flex_scheme.dart';
import 'package:simply_calculator/domain/repositories/app_repository.dart';
import 'package:simply_calculator/i18n/strings.g.dart';

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
    if (isDarkModeLocal == null) {
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      isDarkMode = brightness == Brightness.dark;
    } else {
      isDarkMode = isDarkModeLocal;
    }
    emit(state.copyWith(isDarkMode: isDarkMode));
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
      orElse: () => FlexScheme.flutterDash,
    );
    emit(state.copyWith(theme: theme));
  }

  void _initFontFamily() {
    final fontFamily = appRepository.getFontFamily();
    emit(state.copyWith(fontFamily: fontFamily));
  }
}
