part of 'app_cubit.dart';

class AppState extends Equatable {
  final String language;
  final FlexScheme theme;
  final bool isDarkMode;
  final String? fontFamily;

  const AppState({
    this.language = 'en',
    this.theme = FlexScheme.flutterDash,
    this.isDarkMode = false,
    this.fontFamily,
  });

  AppState copyWith({
    String? language,
    FlexScheme? theme,
    bool? isDarkMode,
    String? fontFamily,
  }) {
    return AppState(
      language: language ?? this.language,
      theme: theme ?? this.theme,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }

  @override
  List<Object?> get props => [language, theme, isDarkMode, fontFamily];
}
