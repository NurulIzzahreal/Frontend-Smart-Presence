import 'package:flutter/material.dart';
import 'package:frontend_smart_presence/models/student.dart';
import 'package:frontend_smart_presence/services/student_service.dart';
import 'package:frontend_smart_presence/screens/teacher/student_form_screen.dart';
import 'package:frontend_smart_presence/utils/csv_importer.dart';

class StudentManagementScreen extends StatefulWidget {
  const StudentManagementScreen({super.key});

  @override
  State<StudentManagementScreen> createState() =>
      _StudentManagementScreenState();
}

class _StudentManagementScreenState extends State<StudentManagementScreen> {
  List<Student> _students = [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final studentService = StudentService();
      final students = await studentService.getAllStudents();
      setState(() {
        _students = students;
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

  Future<void> _refreshStudents() async {
    await _loadStudents();
  }

  void _filterStudents(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  List<Student> _getFilteredStudents() {
    if (_searchQuery.isEmpty) {
      return _students;
    }

    return _students.where((student) {
      final query = _searchQuery.toLowerCase();
      return student.name.toLowerCase().contains(query) ||
          student.studentId.toLowerCase().contains(query) ||
          student.className.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _addStudent() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StudentFormScreen()),
    );

    if (result == true) {
      _loadStudents(); // Refresh the list
    }
  }

  Future<void> _importStudentsFromCSV() async {
    final importedStudents = await CSVImporter.importStudentsFromCSV(context);
    if (importedStudents != null) {
      _loadStudents(); // Refresh the list
    }
  }

  Future<void> _editStudent(Student student) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentFormScreen(student: student),
      ),
    );

    if (result == true) {
      _loadStudents(); // Refresh the list
    }
  }

  Future<void> _deleteStudent(Student student) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: Text('Are you sure you want to delete ${student.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final studentService = StudentService();
        await studentService.deleteStudent(student.id);
        _loadStudents(); // Refresh the list

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Student deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        print('Error deleting student: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete student: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredStudents = _getFilteredStudents();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Management'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshStudents,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search students...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filterStudents,
            ),
          ),

          // Student list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredStudents.isEmpty
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
                          'No students found',
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Add a new student to get started',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredStudents.length,
                    itemBuilder: (context, index) {
                      final student = filteredStudents[index];
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
                          subtitle: Text(
                            '${student.studentId} • ${student.className}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editStudent(student),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteStudent(student),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "import",
            onPressed: _importStudentsFromCSV,
            child: const Icon(Icons.upload_file),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "add",
            onPressed: _addStudent,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
