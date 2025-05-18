import 'dart:io';

import 'package:flutter/foundation.dart';

class AppConst {
  static const String appName = 'Simply Calculator';

  static String getPlatformFontFamily() {
    if (kIsWeb) {
      return 'Roboto';
    }
    if (Platform.isAndroid) {
      return 'Roboto';
    }
    if (Platform.isIOS || Platform.isMacOS) {
      return 'SFPro';
    }
    if (Platform.isWindows) {
      return 'SegoeUI';
    }
    if (Platform.isLinux) {
      return 'Ubuntu';
    }
    return 'Roboto';
  }
}
