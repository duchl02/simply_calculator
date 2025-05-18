import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:simply_calculator/core/firebase/crashlytics/crashlytics.dart';
import 'package:simply_calculator/core/until/notification_utils.dart';
import 'package:simply_calculator/i18n/strings.g.dart';
import 'package:simply_calculator/init_app.dart';
import 'package:simply_calculator/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationUtils.initialize();
  await AppInitializer.init();
  Crashlytics.initCrashlytics();

  runApp(TranslationProvider(child: const MyApp()));
}
