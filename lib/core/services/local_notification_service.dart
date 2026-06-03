import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  static final LocalNotificationService _instance = LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  /// ID untuk notifikasi pengingat harian
  static const int dailyReminderId = 1001;

  Future<void> init() async {
    // Inisialisasi zona waktu timezone
    tz.initializeTimeZones();

    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      debugPrint('Failed to set local timezone, fallback to UTC: $e');
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_notification');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification clicked: ${response.payload}');
      },
    );
  }

  /// Meminta permission notifikasi
  Future<bool> requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    bool? androidGranted = false;
    if (androidImplementation != null) {
      androidGranted = await androidImplementation.requestNotificationsPermission();
      // Minta izin exact alarm untuk Android 12+ agar alarm bisa on-time
      await androidImplementation.requestExactAlarmsPermission();
    }

    final iosGranted = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    return (androidGranted ?? false) || (iosGranted ?? false);
  }

  /// Menjadwalkan pengingat latihan harian pada jam & menit tertentu
  Future<void> scheduleDailyReminder(int hour, int minute) async {
    // Batalkan pengingat lama terlebih dahulu agar tidak duplikat
    await cancelDailyReminder();

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'daily_reminder_channel',
      'Pengingat Latihan Harian',
      channelDescription: 'Menampilkan pengingat untuk latihan pernapasan harian',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const DarwinNotificationDetails darwinPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: darwinPlatformChannelSpecifics,
    );

    // Cari waktu berikutnya untuk hari ini / besok
    final tz.TZDateTime scheduledTime = _nextInstanceOfTime(hour, minute);

    try {
      await _notificationsPlugin.zonedSchedule(
        dailyReminderId,
        'Waktunya Latihan Pernapasan! 🫁',
        'Mari luangkan waktu sejenak untuk melatih paru-paru Anda agar tetap sehat dan kuat.',
        scheduledTime,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Failed to schedule exact alarm: $e. Falling back to inexact.');
      await _notificationsPlugin.zonedSchedule(
        dailyReminderId,
        'Waktunya Latihan Pernapasan! 🫁',
        'Mari luangkan waktu sejenak untuk melatih paru-paru Anda agar tetap sehat dan kuat.',
        scheduledTime,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }

    debugPrint('Daily reminder scheduled at $hour:$minute. Next trigger: $scheduledTime');
  }

  /// Membatalkan pengingat harian
  Future<void> cancelDailyReminder() async {
    await _notificationsPlugin.cancel(dailyReminderId);
    debugPrint('Daily reminder cancelled');
  }

  /// Mencari datetime berikutnya untuk jam & menit yang ditentukan
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  /// Menampilkan notifikasi secara instan (untuk keperluan testing)
  Future<void> showImmediateNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'instant_notification_channel',
      'Notifikasi Instan',
      channelDescription: 'Menampilkan notifikasi seketika',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const DarwinNotificationDetails darwinPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: darwinPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      9999, // ID unik
      title,
      body,
      platformChannelSpecifics,
    );
  }
}
