import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:simply_calculator/di/di.dart' as di;

class AppInitializer {
  static Future<void> init() async {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle());
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    await di.configureInjection();
    await Hive.initFlutter();
  }
}
