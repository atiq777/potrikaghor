import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@drawable/ic_notification');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);

    // Android 13+ permission
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    // Create notification channel explicitly
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'news_channel',
        'নিউজ নোটিফিকেশন',
        description: 'নির্বাচিত পত্রিকার নতুন খবর',
        importance: Importance.high,
      ),
    );

    _initialized = true;
  }

  static Future<void> showNewsNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) await init();

    const androidDetails = AndroidNotificationDetails(
      'news_channel',
      'নিউজ নোটিফিকেশন',
      channelDescription: 'নির্বাচিত পত্রিকার নতুন খবর',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@drawable/ic_notification',
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
      payload: payload,
    );
  }

  static Future<void> showTestNotification() async {
    await showNewsNotification(
      title: 'পত্রিকাঘর',
      body: 'নোটিফিকেশন সঠিকভাবে কাজ করছে! ✓',
    );
  }
}
