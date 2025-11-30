import 'package:flutter/material.dart';
import 'package:frontend_smart_presence/models/user.dart';
import 'package:frontend_smart_presence/services/auth_service.dart';
import 'package:frontend_smart_presence/screens/student/face_enrollment_screen.dart';
import 'package:frontend_smart_presence/models/student.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = AuthService().currentUser;
  }

  Future<void> _enrollFace() async {
    if (_currentUser != null) {
      final student = Student(
        id: _currentUser!.id,
        name: _currentUser!.name,
        email: _currentUser!.email,
        studentId: _currentUser!.studentId ?? '',
        className: _currentUser!.className ?? '',
      );

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FaceEnrollmentScreen(student: student),
        ),
      );

      if (result == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Face enrollment completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            if (_currentUser != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            child: Text(_currentUser!.name.substring(0, 1)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _currentUser!.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(_currentUser!.email),
                                const SizedBox(height: 4),
                                Text(_currentUser!.role),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_currentUser!.studentId != null)
                        Text('Student ID: ${_currentUser!.studentId}'),
                      if (_currentUser!.className != null)
                        Text('Class: ${_currentUser!.className}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Actions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              Card(
                child: ListTile(
                  leading: Icon(
                    Icons.face,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text('Face Enrollment'),
                  subtitle: const Text('Register your face for attendance'),
                  onTap: _enrollFace,
                ),
              ),
            ] else
              const Center(child: Text('No user information available')),
          ],
        ),
      ),
    );
  }
}
