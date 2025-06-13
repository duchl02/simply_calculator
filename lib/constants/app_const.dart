import 'dart:io';

import 'package:flutter/foundation.dart';

class AppConst {
  static const String appName = 'Simply Calculator';
  static const String androidPolicy =
      'https://doc-hosting.flycricket.io/simple-calculator-privacy-policy/56a6a861-2fe5-4145-8f3b-956171deaadf/privacy';
  static const String iosPolicy =
      'https://doc-hosting.flycricket.io/simple-calculator-privacy-policy/56a6a861-2fe5-4145-8f3b-956171deaadf/privacy';

  static String get privacyPolicy {
    if (Platform.isAndroid) {
      return androidPolicy;
    } else if (Platform.isIOS || Platform.isMacOS) {
      return iosPolicy;
    } else {
      return 'https://example.com/privacy-policy'; // Fallback URL
    }
  }

  static const String emailSupport = 'sp.studio.simplycrafted@gmail.com';

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

  static const List<Map<String, String>> languages = [
    {'name': 'English', 'code': 'en', 'flag': '🇺🇸'},
    {'name': 'हिन्दी', 'code': 'hi', 'flag': '🇮🇳'},
    {'name': 'Español', 'code': 'es', 'flag': '🇪🇸'},
    {'name': '简体中文', 'code': 'zh', 'flag': '🇨🇳'},
    {'code': 'ar', 'name': 'العربية', 'flag': '🇸🇦'},
    {'name': 'Português', 'code': 'pt', 'flag': '🇵🇹'},
    {'name': 'বাংলা', 'code': 'bn', 'flag': '🇧🇩'},
    {'name': 'Русский', 'code': 'ru', 'flag': '🇷🇺'},
    {'name': 'Indonesia', 'code': 'id', 'flag': '🇮🇩'},
    {'name': 'Українська', 'code': 'uk', 'flag': '🇺🇦'},
    {'name': 'Français', 'code': 'fr', 'flag': '🇫🇷'},
    {'name': 'Türkçe', 'code': 'tr', 'flag': '🇹🇷'},
    {'name': 'Việt Nam', 'code': 'vi', 'flag': '🇻🇳'},
    {'name': '日本語', 'code': 'ja', 'flag': '🇯🇵'},
    {'name': '한국어', 'code': 'ko', 'flag': '🇰🇷'},
    {'name': 'ไทย', 'code': 'th', 'flag': '🇹🇭'},
    {'name': 'Malay', 'code': 'ms', 'flag': '🇲🇾'},
    {'name': 'Deutsch', 'code': 'de', 'flag': '🇩🇪'},
    {'name': 'Italiano', 'code': 'it', 'flag': '🇮🇹'},
    {'name': 'Urdu', 'code': 'ur', 'flag': '🇵🇰'},
  ];
}
