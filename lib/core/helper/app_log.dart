import 'dart:developer' as developer;

import 'package:logger/logger.dart';

class LogX {
  static Logger logger = Logger();

  static void log(Object message) {
    developer.log('AppLog: ${message.toString()}');
  }

  static void logError({required Object message, StackTrace? stackTrace}) {
    logger.e('AppLog: ${message.toString()} ${stackTrace.toString()}');
  }

  static void logWarning(Object message) {
    logger.w('AppLog: ${message.toString()}');
  }

  static void logInfo({required Object message, StackTrace? stackTrace}) {
    logger.t('AppLog: ${message.toString()} ${stackTrace.toString()}');
  }
}
