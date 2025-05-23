import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simply_calculator/core/helper/app_log.dart';

class DatabaseUtils {
  static Future<String> _getDBPath() async {
    final Directory documentsDirectory =
        await getApplicationDocumentsDirectory();
    return '${documentsDirectory.path}/hive';
  }

  static Future<void> initDatabase() async {
    Hive.init(await _getDBPath());
  }

  static void registerAdapter<T>(TypeAdapter<T> adapter) {
    try {
      Hive.registerAdapter(adapter);
    } on HiveError catch (e, s) {
      LogX.logError(message: 'Failed to register adapter: $e', stackTrace: s);
    }
  }

  static Future<Box<T>> getBox<T>({required String boxName}) async {
    return Hive.openBox<T>(boxName);
  }

  static Future<void> closeBox<T>(Box<T> box) async {
    await box.close();
  }

  static Future<void> clearDatabase() async {
    await Hive.deleteFromDisk();
    await Hive.close();
    final path = await _getDBPath();
    final dir = Directory(path);
    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
  }
}
