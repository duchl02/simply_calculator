part of 'app_cubit.dart';

@freezed
abstract class AppState with _$AppState {
  const factory AppState({
    @Default('en') String language,
    @Default(FlexScheme.flutterDash) FlexScheme theme,
    @Default(false) bool isDarkMode,
    String? fontFamily,
  }) = _AppState;
}
