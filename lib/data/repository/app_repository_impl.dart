import 'package:injectable/injectable.dart';
import 'package:simply_calculator/data/shared_preferences/app_local_data_source.dart';
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
  String getLanguage() {
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
}
