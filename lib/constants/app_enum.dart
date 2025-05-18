enum BlocStatus {
  initial,
  loading,
  updating,
  updateSuccess,
  updateFailed,
  success,
  failure,
  loadingMore,
  loadMoreSuccess,
  loadMoreFailure,
  refreshing,
  exist,
}

enum AppFontFamily {
  jetbrainsMono('JetBrainsMono'),
  robotoMono('RobotoMono'),
  sourceCodePro('SourceCodePro'),
  notoSerif('NotoSerif'),
  robotoSlab('RobotoSlab'),
  merriweather('Merriweather'),
  quicksand('Quicksand'),
  double('DancingScript');

  String get name {
    switch (this) {
      case AppFontFamily.jetbrainsMono:
        return 'JetBrains Mono';
      case AppFontFamily.robotoMono:
        return 'Roboto Mono';
      case AppFontFamily.sourceCodePro:
        return 'Source Code Pro';
      case AppFontFamily.notoSerif:
        return 'Noto Serif';
      case AppFontFamily.robotoSlab:
        return 'Roboto Slab';
      case AppFontFamily.merriweather:
        return 'Merriweather';
      case AppFontFamily.quicksand:
        return 'Quicksand';
      case AppFontFamily.double:
        return 'Dancing Script';
    }
  }

  static AppFontFamily fromId(String id) {
    switch (id) {
      case 'JetBrainsMono':
        return AppFontFamily.jetbrainsMono;
      case 'RobotoMono':
        return AppFontFamily.robotoMono;
      case 'SourceCodePro':
        return AppFontFamily.sourceCodePro;
      case 'NotoSerif':
        return AppFontFamily.notoSerif;
      case 'RobotoSlab':
        return AppFontFamily.robotoSlab;
      case 'Merriweather':
        return AppFontFamily.merriweather;
      case 'Quicksand':
        return AppFontFamily.quicksand;
      case 'DancingScript':
        return AppFontFamily.double;
      default:
        throw ArgumentError('Unknown font family id: $id');
    }
  }

  final String id;
  const AppFontFamily(this.id);
}
