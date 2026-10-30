import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kuliahku/data/models/course_model.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  NotificationService._internal();

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _notificationsPlugin.initialize(initSettings);

    // Request Android 13+ permission
    final androidImpl = _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      await androidImpl.requestNotificationsPermission();
    }
  }

  Future<void> showInstantReminder({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'kuliahku_reminders',
      'Pengingat Jadwal Kuliah',
      channelDescription: 'Notifikasi pengingat sebelum kelas kuliah dimulai',
      importance: Importance.high,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(id, title, body, notificationDetails);
  }

  Future<void> scheduleClassReminder({
    required int id,
    required String title,
    required String body,
    required int dayOfWeek,
    required dynamic startTime,
  }) async {
    // Menjadwalkan pengingat kuliah
  }

  Future<void> scheduleCourseReminder(CourseModel course) async {
    // Schedule notification for class
    // In real app, schedules weekly notification on dayOfWeek at startTime - 30 minutes
  }

  Future<void> cancelReminder(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}
