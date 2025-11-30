import 'package:flutter/material.dart';
import 'package:frontend_smart_presence/services/auth_service.dart';
import 'package:frontend_smart_presence/screens/auth/login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
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
              'Welcome, Admin!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.school,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Manage Schools'),
                subtitle: const Text('Add, edit, or remove schools'),
                onTap: () {
                  // Navigate to school management screen
                  // TODO: Implement school management
                },
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.people,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Manage Teachers'),
                subtitle: const Text('Add, edit, or remove teachers'),
                onTap: () {
                  // Navigate to teacher management screen
                  // TODO: Implement teacher management
                },
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.people_alt,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Manage Students'),
                subtitle: const Text('Add, edit, or remove students'),
                onTap: () {
                  // Navigate to student management screen
                  // TODO: Implement student management
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
                  // TODO: Implement class management
                },
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.bar_chart,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('System Reports'),
                subtitle: const Text('View system-wide reports and analytics'),
                onTap: () {
                  // Navigate to system reports screen
                  // TODO: Implement system reports
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
