import 'package:injectable/injectable.dart';
import 'package:simply_calculator/data/shared_preferences/app_local_data_source.dart';
import 'package:simply_calculator/domain/entities/favorite_calc_item.dart';
import 'package:simply_calculator/domain/repositories/app_repository.dart';

@Injectable(as: AppRepository)
class AppRepositoryImpl implements AppRepository {
  final AppLocalDataSource localDataSource;

  AppRepositoryImpl({required this.localDataSource});
  @override
  Future<void> setFirstTimeOpenApp(int time) {
    return localDataSource.setFirstTimeOpenApp(time);
  }

  @override
  int? getFirstTimeOpenApp() {
    return localDataSource.getFirstTimeOpenApp();
  }

  @override
  Future<void> setLanguage(String language) {
    return localDataSource.setLanguage(language);
  }

  @override
  String? getLanguage() {
    return localDataSource.getLanguage();
  }

  @override
  Future<void> setTheme(String theme) {
    return localDataSource.setTheme(theme);
  }

  @override
  String? getTheme() {
    return localDataSource.getTheme();
  }

  @override
  Future<void> setDarkMode(bool isDarkMode) {
    return localDataSource.setDarkMode(isDarkMode);
  }

  @override
  bool? getDarkMode() {
    return localDataSource.getDarkMode();
  }

  @override
  Future<void> setFontFamily(String fontFamily) {
    return localDataSource.setFontFamily(fontFamily);
  }

  @override
  String getFontFamily() {
    return localDataSource.getFontFamily();
  }

  @override
  Future<void> setFavoriteCalculator(List<FavoriteCalcItem> item) {
    return localDataSource.setFavoriteCalculator(item);
  }

  @override
  List<FavoriteCalcItem> getFavoriteCalculator() {
    return localDataSource.getFavoriteCalculator();
  }

  @override
  Future<void> setDefaultCalculator(String defaultCalculator) {
    return localDataSource.setDefaultCalculator(defaultCalculator);
  }

  @override
  String? getDefaultCalculator() {
    return localDataSource.getDefaultCalculator();
  }

  @override
  bool? getNotificationsEnabled() {
    return localDataSource.getNotificationsEnabled();
  }

  @override
  Future<void> setNotificationsEnabled(bool enabled) {
    return localDataSource.setNotificationsEnabled(enabled);
  }
}
