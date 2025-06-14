part of 'app_cubit.dart';

class AppState extends Equatable {
  final String language;
  final FlexScheme theme;
  final bool isDarkMode;
  final String? fontFamily;
  final ThemeMode? themeMode;
  final String? defaultCalculator;
  final List<FavoriteCalcItem> favorites;

  const AppState({
    this.language = 'en',
    this.theme = FlexScheme.gold,
    this.isDarkMode = false,
    this.themeMode = ThemeMode.system,
    this.fontFamily,
    this.favorites = const [],
    this.defaultCalculator,
  });

  AppState copyWith({
    String? language,
    FlexScheme? theme,
    bool? isDarkMode,
    String? fontFamily,
    ThemeMode? themeMode,
    List<FavoriteCalcItem>? favorites,
    String? defaultCalculator,
  }) {
    return AppState(
      language: language ?? this.language,
      theme: theme ?? this.theme,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      fontFamily: fontFamily ?? this.fontFamily,
      themeMode: themeMode ?? this.themeMode,
      favorites: favorites ?? this.favorites,
      defaultCalculator: defaultCalculator ?? this.defaultCalculator,
    );
  }

  @override
  List<Object?> get props => [
    language,
    theme,
    isDarkMode,
    fontFamily,
    themeMode,
    favorites,
    defaultCalculator,
  ];
}
