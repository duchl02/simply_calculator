import 'package:simply_calculator/domain/entities/favorite_calc_item.dart';

abstract class AppRepository {
  Future<void> setFirstTimeOpenApp(int value);
  int? getFirstTimeOpenApp();

  Future<void> setLanguage(String language);
  String getLanguage();

  Future<void> setTheme(String theme);
  String? getTheme();

  Future<void> setDarkMode(bool isDarkMode);
  bool? getDarkMode();

  Future<void> setFontFamily(String fontFamily);
  String getFontFamily();

  Future<void> setFavoriteCalculator(List<FavoriteCalcItem> item);
  List<FavoriteCalcItem> getFavoriteCalculator();

  Future<void> setDefaultCalculator(String defaultCalculator);
  String? getDefaultCalculator();
}
