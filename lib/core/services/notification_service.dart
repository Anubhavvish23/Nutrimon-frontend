import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart' show Color;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'api_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _local_notifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'nutrimorning_channel',
    'NutriMorning Notifications',
    description: 'Health and breakfast reminders',
    importance: Importance.high,
  );

  static const List<({int id, int hour, int minute, String title, String body})>
      _daily_reminders = [
    (
      id: 100,
      hour: 6,
      minute: 30,
      title: 'Good morning!',
      body: 'Wakey wakey — breakfast time! Start your day with a nutritious meal.',
    ),
    (
      id: 101,
      hour: 12,
      minute: 30,
      title: 'Lunch time',
      body: 'Fuel up with a balanced lunch to keep your energy steady.',
    ),
    (
      id: 102,
      hour: 19,
      minute: 0,
      title: 'Dinner reminder',
      body: 'Time for dinner — check your meal plan for tonight\'s ideas.',
    ),
    (
      id: 103,
      hour: 21,
      minute: 30,
      title: 'Wind down',
      body: 'Hydrate and log your meals to keep your streak going.',
    ),
  ];

  static Future<void> initialize() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    tz_data.initializeTimeZones();

    final android_plugin = _local_notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await android_plugin?.createNotificationChannel(_channel);
    await android_plugin?.requestNotificationsPermission();
    await android_plugin?.requestExactAlarmsPermission();

    const android_settings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const init_settings = InitializationSettings(android: android_settings);
    await _local_notifications.initialize(init_settings);

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _show_local_notification(message);
    });

    if (settings.authorizationStatus != AuthorizationStatus.denied) {
      await _schedule_daily_reminders();
    }

    final token = await _messaging.getToken();
    if (token != null) {
      await ApiService.registerFCMToken(token: token);
    }

    _messaging.onTokenRefresh.listen((new_token) async {
      await ApiService.registerFCMToken(token: new_token);
    });
  }

  static Future<void> _show_local_notification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _local_notifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      _notification_details(),
    );
  }

  static NotificationDetails _notification_details() {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: Importance.high,
        priority: Priority.high,
        color: const Color(0xFF1DB954),
        icon: '@mipmap/ic_launcher',
      ),
    );
  }

  static Future<void> _schedule_daily_reminders() async {
    for (final reminder in _daily_reminders) {
      await _local_notifications.zonedSchedule(
        reminder.id,
        reminder.title,
        reminder.body,
        _next_instance(reminder.hour, reminder.minute),
        _notification_details(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  static tz.TZDateTime _next_instance(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  static Future<String?> getToken() async {
    return await _messaging.getToken();
  }
}
