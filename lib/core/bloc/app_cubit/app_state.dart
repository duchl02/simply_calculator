part of 'app_cubit.dart';

class AppState extends Equatable {
  final String language;
  final FlexScheme theme;
  final bool isDarkMode;
  final String? fontFamily;
  final ThemeMode? themeMode;

  const AppState({
    this.language = 'en',
    this.theme = FlexScheme.flutterDash,
    this.isDarkMode = false,
    this.themeMode = ThemeMode.system,
    this.fontFamily,
  });

  AppState copyWith({
    String? language,
    FlexScheme? theme,
    bool? isDarkMode,
    String? fontFamily,
    ThemeMode? themeMode,
  }) {
    return AppState(
      language: language ?? this.language,
      theme: theme ?? this.theme,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      fontFamily: fontFamily ?? this.fontFamily,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  List<Object?> get props => [language, theme, isDarkMode, fontFamily, themeMode];
}
