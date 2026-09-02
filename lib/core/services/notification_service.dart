import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart' show Color, debugPrint;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'api_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await NotificationService.ensure_local_plugin();
  await NotificationService.show_from_message(message);
}

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _local_notifications =
      FlutterLocalNotificationsPlugin();
  static bool _local_ready = false;
  static bool _initialized = false;

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

  static Future<void> register_background_handler() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    await ensure_local_plugin();

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(show_from_message);

    if (settings.authorizationStatus != AuthorizationStatus.denied) {
      await reschedule_daily_reminders();
    }

    await sync_token();
    _messaging.onTokenRefresh.listen((_) {
      sync_token();
    });
  }

  static Future<void> ensure_local_plugin() async {
    if (_local_ready) return;

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
    _local_ready = true;
  }

  static Future<void> reschedule_daily_reminders() async {
    await ensure_local_plugin();

    for (final reminder in _daily_reminders) {
      await _local_notifications.cancel(reminder.id);
    }

    for (final reminder in _daily_reminders) {
      await _schedule_one(
        reminder.id,
        reminder.title,
        reminder.body,
        reminder.hour,
        reminder.minute,
      );
    }
  }

  static Future<void> show_from_message(RemoteMessage message) async {
    final notification = message.notification;
    final title = notification?.title ?? message.data['title'];
    final body = notification?.body ?? message.data['body'];
    if (title == null && body == null) return;

    await ensure_local_plugin();
    await _local_notifications.show(
      notification?.hashCode ?? message.hashCode,
      title,
      body,
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

  static Future<void> _schedule_one(
    int id,
    String title,
    String body,
    int hour,
    int minute,
  ) async {
    final when = _next_instance(hour, minute);
    try {
      await _local_notifications.zonedSchedule(
        id,
        title,
        body,
        when,
        _notification_details(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Exact alarm schedule failed for $id: $e');
      await _local_notifications.zonedSchedule(
        id,
        title,
        body,
        when,
        _notification_details(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
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
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  static Future<void> sync_token() async {
    try {
      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) return;
      await ApiService.registerFCMToken(token: token);
    } catch (e) {
      debugPrint('FCM token sync failed: $e');
    }
  }

  static Future<String?> getToken() async {
    return await _messaging.getToken();
  }
}
