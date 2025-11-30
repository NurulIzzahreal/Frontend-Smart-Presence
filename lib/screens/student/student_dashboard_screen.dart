import 'package:flutter/material.dart';
import 'package:frontend_smart_presence/services/auth_service.dart';
import 'package:frontend_smart_presence/screens/auth/login_screen.dart';
import 'package:frontend_smart_presence/screens/student/face_recognition_screen.dart';
import 'package:frontend_smart_presence/screens/student/attendance_history_screen.dart';
import 'package:frontend_smart_presence/screens/student/profile_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
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
              'Welcome, Student!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.camera_alt,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Take Attendance'),
                subtitle: const Text(
                  'Use face recognition to mark your attendance',
                ),
                onTap: () {
                  // Navigate to face recognition screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FaceRecognitionScreen(
                        studentId:
                            'STUDENT_ID', // This should be the actual student ID
                        classId:
                            'CLASS_ID', // This should be the actual class ID
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.history,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Attendance History'),
                subtitle: const Text('View your attendance records'),
                onTap: () {
                  // Navigate to attendance history screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AttendanceHistoryScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Profile'),
                subtitle: const Text('View and edit your profile'),
                onTap: () {
                  // Navigate to profile screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
