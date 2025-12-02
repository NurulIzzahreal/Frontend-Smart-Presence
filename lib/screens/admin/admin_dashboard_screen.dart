import 'package:flutter/material.dart';
import 'package:frontend_smart_presence/services/auth_service.dart';
import 'package:frontend_smart_presence/screens/auth/login_screen.dart';
import 'package:frontend_smart_presence/services/statistics_service.dart';
import 'package:frontend_smart_presence/services/attendance_service.dart';
import 'package:frontend_smart_presence/services/student_service.dart';
import 'package:frontend_smart_presence/services/class_service.dart';
import 'package:frontend_smart_presence/models/attendance.dart';
import 'package:frontend_smart_presence/models/student.dart';
import 'package:frontend_smart_presence/models/class_model.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<Attendance> _attendanceRecords = [];
  List<Student> _students = [];
  List<ClassModel> _classes = [];
  bool _isLoading = false;
  Map<String, dynamic> _statistics = {};
  List<Map<String, dynamic>> _abnormalities = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load all data in parallel
      final attendanceService = AttendanceService();
      final studentService = StudentService();
      final classService = ClassService();

      final futureAttendance = attendanceService.getAllAttendance();
      final futureStudents = studentService.getAllStudents();
      final futureClasses = classService.getAllClasses();

      final attendance = await futureAttendance;
      final students = await futureStudents;
      final classes = await futureClasses;

      setState(() {
        _attendanceRecords = attendance;
        _students = students;
        _classes = classes;
      });

      // Calculate statistics
      final statisticsService = StatisticsService();
      final statistics = statisticsService.calculateAttendanceStatistics(
        attendance,
        students,
        classes,
      );

      final abnormalities = statisticsService.identifyAbnormalPatterns(
        attendance,
      );

      setState(() {
        _statistics = statistics;
        _abnormalities = abnormalities;
      });
    } catch (e) {
      print('Error loading dashboard data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load dashboard data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshDashboard() async {
    await _loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshDashboard,
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshDashboard,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome, Admin!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Summary Statistics Cards
                      if (_statistics.isNotEmpty) ...[
                        _buildSummaryCards(),
                        const SizedBox(height: 20),
                      ],

                      // Abnormalities Section
                      if (_abnormalities.isNotEmpty) ...[
                        _buildAbnormalitiesSection(),
                        const SizedBox(height: 20),
                      ],

                      // Recent Attendance
                      _buildRecentAttendanceSection(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Summary Statistics',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildStatCard(
              'Total Students',
              _statistics['studentsCount'].toString(),
              Icons.people,
              Colors.blue,
            ),
            const SizedBox(width: 10),
            _buildStatCard(
              'Total Classes',
              _statistics['classesCount'].toString(),
              Icons.class_,
              Colors.green,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildStatCard(
              'Attendance Rate',
              '${_statistics['attendanceRate'].toStringAsFixed(1)}%',
              Icons.percent,
              Colors.purple,
            ),
            const SizedBox(width: 10),
            _buildStatCard(
              'Avg Confidence',
              '${(_statistics['averageConfidence'] * 100).toStringAsFixed(1)}%',
              Icons.bar_chart,
              Colors.orange,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildStatCard(
              'Present',
              _statistics['presentCount'].toString(),
              Icons.check_circle,
              Colors.green,
            ),
            const SizedBox(width: 10),
            _buildStatCard(
              'Late',
              _statistics['lateCount'].toString(),
              Icons.access_time,
              Colors.orange,
            ),
            const SizedBox(width: 10),
            _buildStatCard(
              'Absent',
              _statistics['absentCount'].toString(),
              Icons.cancel,
              Colors.red,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAbnormalitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Abnormal Patterns Detected',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _abnormalities.length,
          itemBuilder: (context, index) {
            final abnormality = _abnormalities[index];
            final severity = abnormality['severity'] as String;
            final color = severity == 'high'
                ? Colors.red
                : severity == 'medium'
                ? Colors.orange
                : Colors.yellow;

            return Card(
              color: color.withOpacity(0.1),
              child: ListTile(
                leading: Icon(
                  severity == 'high' ? Icons.error : Icons.warning,
                  color: color,
                ),
                title: Text(
                  abnormality['message'] as String,
                  style: TextStyle(color: color),
                ),
                subtitle: abnormality.containsKey('date')
                    ? Text('Date: ${abnormality['date']}')
                    : null,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentAttendanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Attendance',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        _attendanceRecords.isEmpty
            ? const Center(child: Text('No attendance records found'))
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _attendanceRecords.length > 5
                    ? 5
                    : _attendanceRecords.length,
                itemBuilder: (context, index) {
                  final record = _attendanceRecords[index];
                  final student = _students.firstWhere(
                    (s) => s.id == record.studentId,
                    orElse: () => Student(
                      id: record.studentId,
                      name: 'Unknown Student',
                      email: '',
                      studentId: record.studentId,
                      className: '',
                    ),
                  );

                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(student.name.substring(0, 1)),
                      ),
                      title: Text(student.name),
                      subtitle: Text(
                        '${_formatDate(record.timestamp)} - ${record.status}',
                      ),
                      trailing: Text(
                        '${(record.confidenceScore * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
