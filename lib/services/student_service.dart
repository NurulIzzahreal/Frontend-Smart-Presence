import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend_smart_presence/models/student.dart';
import 'package:frontend_smart_presence/services/auth_service.dart';

class StudentService {
  static const String baseUrl = 'http://localhost:8000/api';

  final AuthService _authService = AuthService();

  // Get all students
  Future<List<Student>> getAllStudents() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/students'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authService.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Student.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load students');
      }
    } catch (e) {
      print('Error fetching students: $e');
      throw Exception('Failed to load students: $e');
    }
  }

  // Get student by ID
  Future<Student> getStudentById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/students/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authService.token}',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Student.fromJson(data);
      } else {
        throw Exception('Failed to load student');
      }
    } catch (e) {
      print('Error fetching student: $e');
      throw Exception('Failed to load student: $e');
    }
  }

  // Create a new student
  Future<Student> createStudent(Student student) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/students'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authService.token}',
        },
        body: jsonEncode(student.toJson()),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Student.fromJson(data);
      } else {
        throw Exception('Failed to create student');
      }
    } catch (e) {
      print('Error creating student: $e');
      throw Exception('Failed to create student: $e');
    }
  }

  // Update a student
  Future<Student> updateStudent(String id, Student student) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/students/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authService.token}',
        },
        body: jsonEncode(student.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Student.fromJson(data);
      } else {
        throw Exception('Failed to update student');
      }
    } catch (e) {
      print('Error updating student: $e');
      throw Exception('Failed to update student: $e');
    }
  }

  // Delete a student
  Future<void> deleteStudent(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/students/$id'),
        headers: {'Authorization': 'Bearer ${_authService.token}'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete student');
      }
    } catch (e) {
      print('Error deleting student: $e');
      throw Exception('Failed to delete student: $e');
    }
  }

  // Import students from CSV
  Future<List<Student>> importStudentsFromCSV(String csvData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/students/import'),
        headers: {
          'Content-Type': 'text/csv',
          'Authorization': 'Bearer ${_authService.token}',
        },
        body: csvData,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Student.fromJson(json)).toList();
      } else {
        throw Exception('Failed to import students');
      }
    } catch (e) {
      print('Error importing students: $e');
      throw Exception('Failed to import students: $e');
    }
  }
}
