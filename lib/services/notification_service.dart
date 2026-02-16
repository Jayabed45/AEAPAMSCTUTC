import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:io';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // 1. Request Permission
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      criticalAlert: true,
    );

    debugPrint('User granted permission: ${settings.authorizationStatus}');

    // 2. Setup Local Notifications
    await _setupLocalNotifications();

    // Subscribe to global alerts topic for background notifications even without auth
    try {
      await _fcm.subscribeToTopic('system_alerts');
      debugPrint('Subscribed to topic: system_alerts');
    } catch (e) {
      debugPrint('Topic subscription failed: $e');
    }

    // Update FCM foreground presentation options
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

    // 3. Handle Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("Received foreground message: ${message.notification?.title}");
      _showLocalNotification(message);
      _saveNotificationToFirestore(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("App opened via notification: ${message.notification?.title}");
    });

    // Check if the app was opened from a terminated state via a notification
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      debugPrint(
        "App opened from terminated state: ${initialMessage.notification?.title}",
      );
    }

    // 4. Get Token
    String? token = await _fcm.getToken(
      vapidKey:
          'BKBzxC20qs6ELR8qaVanogGzngXAyIpioyK9yg-9_PVXsqBP8hzYEovbDmlTur1kzxZdQIF_HMGct04nbXT7AeY',
    );
    debugPrint("FCM Token: $token");
    if (token != null) {
      await saveTokenToDatabase(token);
    }

    // Listen for token refresh
    _fcm.onTokenRefresh.listen((newToken) {
      saveTokenToDatabase(newToken);
    });

    _isInitialized = true;
  }

  /// Specialized initialization for background isolates
  Future<void> initializeForBackground() async {
    await _setupLocalNotifications();
  }

  Future<void> _setupLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    // Create high importance channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important system alerts.',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    await _localNotifications.initialize(initializationSettings);
  }

  Future<void> saveTokenToDatabase(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('tokens')
          .doc(token)
          .set({
            'token': token,
            'createdAt': FieldValue.serverTimestamp(),
            'platform': Platform.isAndroid ? 'android' : 'ios',
          });
      debugPrint('Token saved to Firestore successfully');
    } catch (e) {
      debugPrint('Error saving token to Firestore: $e');
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'System Alert',
      message.notification?.body ?? '',
      platformChannelSpecifics,
    );
  }

  // Trigger a notification manually (for system anomalies)
  Future<void> showManualNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  Future<void> _saveNotificationToFirestore(RemoteMessage message) async {
    try {
      await _firestore.collection('notifications').add({
        'title': message.notification?.title ?? 'System Alert',
        'description': message.notification?.body ?? '',
        'time': DateFormat('hh:mm a').format(DateTime.now()),
        'is_unread': true,
        'icon_name': getIconForTitle(message.notification?.title ?? ''),
        'icon_color_hex': getColorForTitle(message.notification?.title ?? ''),
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error saving notification: $e');
    }
  }

  String getIconForTitle(String title) {
    title = title.toLowerCase();
    if (title.contains('temperature')) return 'thermostat_rounded';
    if (title.contains('water')) return 'water_drop_rounded';
    if (title.contains('voltage') || title.contains('power')) return 'bolt';
    if (title.contains('offline')) return 'cloud_off';
    if (title.contains('warning')) return 'warning_amber_rounded';
    if (title.contains('success')) return 'check_circle_outline_rounded';
    return 'notifications';
  }

  String getColorForTitle(String title) {
    title = title.toLowerCase();
    if (title.contains('high') ||
        title.contains('critical') ||
        title.contains('alert')) {
      return '#F44336'; // Red
    }
    if (title.contains('warning') || title.contains('caution')) {
      return '#FF9800'; // Orange
    }
    return '#2196F3'; // Blue
  }
}
