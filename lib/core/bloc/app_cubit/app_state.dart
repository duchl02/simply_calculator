part of 'app_cubit.dart';

class AppState extends Equatable {
  final String language;
  final FlexScheme theme;
  final bool isDarkMode;
  final String? fontFamily;
  final ThemeMode? themeMode;
  final FavoriteCalcItem? favoriteCalcItem;
  final List<FavoriteCalcItem> favorites;

  const AppState({
    this.language = 'en',
    this.theme = FlexScheme.flutterDash,
    this.isDarkMode = false,
    this.themeMode = ThemeMode.system,
    this.fontFamily,
    this.favoriteCalcItem,
    this.favorites = const [],
  });

  AppState copyWith({
    String? language,
    FlexScheme? theme,
    bool? isDarkMode,
    String? fontFamily,
    ThemeMode? themeMode,
    FavoriteCalcItem? favoriteCalcItem,
    List<FavoriteCalcItem>? favorites,
  }) {
    return AppState(
      language: language ?? this.language,
      theme: theme ?? this.theme,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      fontFamily: fontFamily ?? this.fontFamily,
      themeMode: themeMode ?? this.themeMode,
      favoriteCalcItem: favoriteCalcItem ?? this.favoriteCalcItem,
      favorites: favorites ?? this.favorites,
    );
  }

  @override
  List<Object?> get props => [
    language,
    theme,
    isDarkMode,
    fontFamily,
    themeMode,
    favoriteCalcItem,
    favorites,
  ];
}
