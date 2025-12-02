import 'package:flutter/material.dart';
import 'package:frontend_smart_presence/services/auth_service.dart';
import 'package:frontend_smart_presence/screens/auth/login_screen.dart';
import 'package:frontend_smart_presence/screens/teacher/student_management_screen.dart';
import 'package:frontend_smart_presence/screens/teacher/class_management_screen.dart';
import 'package:frontend_smart_presence/screens/teacher/take_attendance_screen.dart';
import 'package:frontend_smart_presence/screens/teacher/attendance_reports_screen.dart';
import 'package:frontend_smart_presence/services/notification_service.dart';
import 'package:frontend_smart_presence/services/statistics_service.dart';
import 'package:frontend_smart_presence/services/attendance_service.dart';
import 'package:frontend_smart_presence/services/student_service.dart';
import 'package:frontend_smart_presence/services/class_service.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  final NotificationService _notificationService = NotificationService();
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
    final enabled = await _notificationService.areNotificationsEnabled();
    setState(() {
      _notificationsEnabled = enabled;
    });

    if (!enabled) {
      await _notificationService.requestNotificationPermissions();
    }
  }

  Future<void> _checkForAbnormalAttendance() async {
    try {
      // In a real implementation, this would check actual attendance data
      // For demo purposes, we'll simulate an abnormal pattern
      await Future.delayed(const Duration(seconds: 2));

      // Send notification about abnormal attendance
      await _notificationService.sendAbnormalAttendanceNotification(
        'Unusual attendance pattern detected in Class A',
        5, // Number of affected students
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Abnormal attendance notification sent'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error checking for abnormal attendance: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              _notificationsEnabled
                  ? Icons.notifications_active
                  : Icons.notifications_off,
              color: _notificationsEnabled ? Colors.white : Colors.red,
            ),
            onPressed: _initializeNotifications,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome, Teacher!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.people,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Manage Students'),
                subtitle: const Text('Add, edit, or remove students'),
                onTap: () {
                  // Navigate to student management screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StudentManagementScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.class_,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Manage Classes'),
                subtitle: const Text('Create or edit class schedules'),
                onTap: () {
                  // Navigate to class management screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ClassManagementScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.camera_alt,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Take Attendance'),
                subtitle: const Text(
                  'Start attendance session with face recognition',
                ),
                onTap: () {
                  // Navigate to attendance taking screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TakeAttendanceScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.analytics,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Attendance Reports'),
                subtitle: const Text('View and export attendance reports'),
                onTap: () {
                  // Navigate to attendance reports screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AttendanceReportsScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.warning,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Check Abnormal Attendance'),
                subtitle: const Text('Detect unusual attendance patterns'),
                onTap: _checkForAbnormalAttendance,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
