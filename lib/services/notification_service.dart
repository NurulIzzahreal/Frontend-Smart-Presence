import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frontend_smart_presence/models/attendance.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);
  }

  // Send notification to teacher about abnormal attendance
  Future<void> sendAbnormalAttendanceNotification(
    String message,
    int abnormalCount,
  ) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'abnormal_attendance_channel',
          'Abnormal Attendance',
          channelDescription: 'Notifications for abnormal attendance patterns',
          importance: Importance.high,
          priority: Priority.high,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await _notificationsPlugin.show(
      0,
      'Abnormal Attendance Alert',
      '$message\n$abnormalCount students affected',
      notificationDetails,
    );
  }

  // Send notification to parent about student absence
  Future<void> sendParentAbsenceNotification(
    String parentName,
    String studentName,
    DateTime absenceDate,
  ) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'parent_notification_channel',
          'Parent Notification',
          channelDescription:
              'Notifications for parents about student attendance',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await _notificationsPlugin.show(
      1,
      'Student Absence Notification',
      'Dear $parentName,\nYour child $studentName was absent on ${_formatDate(absenceDate)}.',
      notificationDetails,
    );
  }

  // Send notification about system events
  Future<void> sendSystemNotification(String title, String message) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'system_notification_channel',
          'System Notification',
          channelDescription: 'System notifications',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await _notificationsPlugin.show(2, title, message, notificationDetails);
  }

  // Send reminder notification
  Future<void> sendReminderNotification(
    String title,
    String message,
    DateTime scheduledTime,
  ) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'reminder_notification_channel',
          'Reminder',
          channelDescription: 'Reminder notifications',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await _notificationsPlugin.schedule(
      3,
      title,
      message,
      scheduledTime,
      notificationDetails,
    );
  }

  // Format date for display
  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    return await _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.areNotificationsEnabled() ??
        false;
  }

  // Request notification permissions
  Future<void> requestNotificationPermissions() async {
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }
}
