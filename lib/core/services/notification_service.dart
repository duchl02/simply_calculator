import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:simply_calculator/core/firebase/analytics/analytics_util.dart';
import 'package:simply_calculator/core/helper/app_log.dart';
import 'package:simply_calculator/di/di.dart';
import 'package:simply_calculator/domain/repositories/app_repository.dart';

// Firebase messaging background handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
    LogX.logInfo(message: 'Handled background message: ${message.messageId}');
  } catch (e) {
    LogX.logError(message: 'Error handling background message: $e');
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  final AppRepository _appRepository = getIt<AppRepository>();
  bool _isFirebaseInitialized = false;
  
  // Android notification channel for Firebase messages
  late AndroidNotificationChannel _highImportanceChannel;

  // Setup Firebase notifications
  Future<void> setupFirebaseNotifications() async {
    if (_isFirebaseInitialized) return;
    
    try {
      _highImportanceChannel = const AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.high,
      );

      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_highImportanceChannel);

      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      _isFirebaseInitialized = true;
    } catch (e) {
      LogX.logError(message: 'Failed to setup Firebase notifications: $e');
    }
  }

  // Main initialization method
  Future<void> initialize() async {
    try {
      // Initialize local notifications (needed for Firebase)
      await _initializeLocalNotifications();
      
      // Request permissions
      await _requestPermissions();
      
      // Setup Firebase handlers
      _setupFirebaseHandlers();
    } catch (e) {
      LogX.logError(message: 'Failed to initialize notification service: $e');
    }
  }

  // Initialize local notifications plugin (needed for Firebase display)
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    // Create main Firebase channel
    if (Platform.isAndroid) {
      _highImportanceChannel = const AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.high,
      );
      
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_highImportanceChannel);
    }
  }

  // Setup Firebase messaging handlers
  void _setupFirebaseHandlers() {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      try {
        LogX.logInfo(message: 'Received foreground message: ${message.messageId}');
        
        if (message.notification != null) {
          _showFirebaseNotification(message);
        }
      } catch (e) {
        LogX.logError(message: 'Error handling foreground message: $e');
      }
    });
    
    // Get FCM token
    _fetchAndLogFCMToken();
  }

  // Show Firebase notification
  void _showFirebaseNotification(RemoteMessage message) {
    if (!Platform.isAndroid || message.notification == null) return;
    
    _notificationsPlugin.show(
      message.hashCode,
      message.notification!.title,
      message.notification!.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _highImportanceChannel.id,
          _highImportanceChannel.name,
          channelDescription: _highImportanceChannel.description,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: 'fcm_notification',
    );
  }

  // Get FCM token
  Future<void> _fetchAndLogFCMToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      LogX.logInfo(message: 'FCM Token: $token');
    } catch (e) {
      LogX.logError(message: 'Failed to get FCM token: $e');
    }
  }

  // Request notification permissions
  Future<void> _requestPermissions() async {
    try {
      if (Platform.isAndroid) {
        final plugin = _notificationsPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        await plugin?.requestNotificationsPermission();
      }
      
      if (Platform.isIOS) {
        await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
      }
    } catch (e) {
      LogX.logError(message: 'Failed to request notification permissions: $e');
    }
  }

  // Handle notification taps
  void _onNotificationTapped(NotificationResponse details) {
    try {
      AnalyticsUtil.logEvent('notification_tapped', {
        'notification_id': details.id ?? 0,
        'notification_type': details.payload ?? 'unknown',
      });
    } catch (e) {
      LogX.logError(message: 'Error handling notification tap: $e');
    }
  }
  
  // Check notification permissions
  Future<bool> checkNotificationPermissions() async {
    try {
      if (Platform.isAndroid) {
        final plugin = _notificationsPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
            
        final status = await plugin?.areNotificationsEnabled() ?? false;
        LogX.logInfo(message: 'Android notification permissions status: $status');
        return status;
      }
      
      if (Platform.isIOS) {
        final settings = await FirebaseMessaging.instance.getNotificationSettings();
        final granted = settings.authorizationStatus == AuthorizationStatus.authorized;
        LogX.logInfo(message: 'iOS notification permissions status: $granted');
        return granted;
      }
      
      return false;
    } catch (e) {
      LogX.logError(message: 'Error checking notification permissions: $e');
      return false;
    }
  }

  // For the toggle in settings - now only affects Firebase
  Future<bool> areNotificationsEnabled() async {
    try {
      return _appRepository.getNotificationsEnabled() ?? true;
    } catch (e) {
      LogX.logError(message: 'Error checking if notifications are enabled: $e');
      return false;
    }
  }

  // Store notification preference - for Firebase only
  Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      await _appRepository.setNotificationsEnabled(enabled);
      
      if (enabled) {
        await FirebaseMessaging.instance.requestPermission();
      } else {
        // On iOS we can't really disable, but on Android we can
        if (Platform.isAndroid) {
          await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
            alert: false,
            badge: false,
            sound: false,
          );
        }
      }
    } catch (e) {
      LogX.logError(message: 'Error setting notifications enabled: $e');
    }
  }
}
