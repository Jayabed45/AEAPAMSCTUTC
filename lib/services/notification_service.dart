import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initialize() async {
    // 1. Request Permission
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      criticalAlert: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    }
                                                                                                                                                                                                            
    // 2. Setup Local Notifications for Foreground
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    // Create high importance channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
          'This channel is used for important system alerts.', // description
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    await _localNotifications.initialize(initializationSettings);

    // Update FCM foreground presentation options
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

    // 3. Handle Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
      _saveNotificationToFirestore(message);
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 4. Get Token (using VAPID key for web support)
    String? token = await _fcm.getToken(
      vapidKey:
          'BKBzxC20qs6ELR8qaVanogGzngXAyIpioyK9yg-9_PVXsqBP8hzYEovbDmlTur1kzxZdQIF_HMGct04nbXT7AeY',
    );
    print("FCM Token: $token");
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
      print('Error saving notification: $e');
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
        title.contains('alert'))
      return '#F44336'; // Red
    if (title.contains('warning') || title.contains('caution'))
      return '#FF9800'; // Orange
    return '#2196F3'; // Blue
  }
}

// Background handler must be top-level
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // This is handled by FCM automatically on most platforms,
  // but we can add custom logic here if needed.
  print("Handling a background message: ${message.messageId}");
}
