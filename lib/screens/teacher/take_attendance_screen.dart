import 'package:flutter/material.dart';
import 'package:frontend_smart_presence/models/student.dart';
import 'package:frontend_smart_presence/models/class_model.dart';
import 'package:frontend_smart_presence/services/student_service.dart';
import 'package:frontend_smart_presence/services/class_service.dart';
import 'package:frontend_smart_presence/services/attendance_service.dart';

class TakeAttendanceScreen extends StatefulWidget {
  const TakeAttendanceScreen({super.key});

  @override
  State<TakeAttendanceScreen> createState() => _TakeAttendanceScreenState();
}

class _TakeAttendanceScreenState extends State<TakeAttendanceScreen> {
  List<Student> _students = [];
  List<ClassModel> _classes = [];
  String? _selectedClassId;
  bool _isLoading = false;
  Map<String, String> _attendanceStatus = {}; // studentId -> status

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final classService = ClassService();
      final classes = await classService.getAllClasses();
      setState(() {
        _classes = classes;
      });
    } catch (e) {
      print('Error loading classes: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load classes: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadStudentsByClass(String classId) async {
    setState(() {
      _isLoading = true;
      _selectedClassId = classId;
      _attendanceStatus.clear();
    });

    try {
      final studentService = StudentService();
      final students = await studentService.getAllStudents();
      // Filter students by class (in a real app, this would be done on the backend)
      final classStudents = students
          .where(
            (student) =>
                student.className ==
                _classes.firstWhere((c) => c.id == classId).name,
          )
          .toList();

      setState(() {
        _students = classStudents;
      });
    } catch (e) {
      print('Error loading students: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load students: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _setAttendanceStatus(String studentId, String status) {
    setState(() {
      _attendanceStatus[studentId] = status;
    });
  }

  Future<void> _submitAttendance() async {
    if (_selectedClassId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a class first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_attendanceStatus.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please mark attendance for at least one student'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final attendanceService = AttendanceService();
      int successCount = 0;

      for (final entry in _attendanceStatus.entries) {
        final studentId = entry.key;
        final status = entry.value;

        try {
          await attendanceService.markAttendanceManually(
            studentId,
            _selectedClassId!,
            status,
          );
          successCount++;
        } catch (e) {
          print('Error marking attendance for student $studentId: $e');
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Attendance recorded for $successCount students'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear attendance status
      setState(() {
        _attendanceStatus.clear();
      });
    } catch (e) {
      print('Error submitting attendance: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit attendance: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Take Attendance'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Class selection
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'Select Class',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedClassId,
                  decoration: const InputDecoration(
                    labelText: 'Class',
                    border: OutlineInputBorder(),
                  ),
                  items: _classes.map((classModel) {
                    return DropdownMenuItem(
                      value: classModel.id,
                      child: Text(
                        '${classModel.name} - ${classModel.schedule}',
                      ),
                    );
                  }).toList(),
                  onChanged: _isLoading
                      ? null
                      : (value) {
                          if (value != null) {
                            _loadStudentsByClass(value);
                          }
                        },
                ),
              ],
            ),
          ),

          // Students list
          Expanded(
            child: _isLoading && _selectedClassId == null
                ? const Center(child: CircularProgressIndicator())
                : _selectedClassId == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.class_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Please select a class to take attendance',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  )
                : _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _students.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'No students found in this class',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _students.length,
                    itemBuilder: (context, index) {
                      final student = _students[index];
                      final status = _attendanceStatus[student.id] ?? 'absent';

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(student.name.substring(0, 1)),
                          ),
                          title: Text(student.name),
                          subtitle: Text('${student.studentId}'),
                          trailing: SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(value: 'present', label: Text('P')),
                              ButtonSegment(value: 'late', label: Text('L')),
                              ButtonSegment(value: 'absent', label: Text('A')),
                            ],
                            selected: {status},
                            onSelectionChanged: (Set<String> newSelection) {
                              _setAttendanceStatus(
                                student.id,
                                newSelection.first,
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Submit button
          if (_selectedClassId != null && _students.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitAttendance,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Submit Attendance',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
