import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simply_calculator/constants/app_const.dart';
import 'package:simply_calculator/data/local/local_storage_key.dart';

@injectable
class AppLocalDataSource {
  final SharedPreferences sharedPreferences;
  AppLocalDataSource(this.sharedPreferences);

  Future<void> setFirstTimeOpenApp(int time) async {
    await sharedPreferences.setInt(LocalStorageKey.firstTimeOpenApp, time);
  }

  int? getFirstTimeOpenApp() {
    return sharedPreferences.getInt(LocalStorageKey.firstTimeOpenApp);
  }

  Future<void> setLanguage(String language) async {
    await sharedPreferences.setString(LocalStorageKey.language, language);
  }

  String getLanguage() {
    return sharedPreferences.getString(LocalStorageKey.language) ?? 'en';
  }

  Future<void> setTheme(String theme) async {
    await sharedPreferences.setString(LocalStorageKey.theme, theme);
  }

  String? getTheme() {
    return sharedPreferences.getString(LocalStorageKey.theme);
  }

  Future<void> setDarkMode(bool isDarkMode) async {
    await sharedPreferences.setBool(LocalStorageKey.darkMode, isDarkMode);
  }

  bool? getDarkMode() {
    return sharedPreferences.getBool(LocalStorageKey.darkMode);
  }

  Future<void> setFontFamily(String fontFamily) async {
    await sharedPreferences.setString(LocalStorageKey.fontFamily, fontFamily);
  }

  String getFontFamily() {
    return sharedPreferences.getString(LocalStorageKey.fontFamily) ??
        AppConst.getPlatformFontFamily();
  }
}
