import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend_smart_presence/models/class_model.dart';
import 'package:frontend_smart_presence/services/auth_service.dart';

class ClassService {
  static const String baseUrl = 'http://localhost:8000/api';

  final AuthService _authService = AuthService();

  // Get all classes
  Future<List<ClassModel>> getAllClasses() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/classes'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authService.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ClassModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load classes');
      }
    } catch (e) {
      print('Error fetching classes: $e');
      throw Exception('Failed to load classes: $e');
    }
  }

  // Get class by ID
  Future<ClassModel> getClassById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/classes/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authService.token}',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ClassModel.fromJson(data);
      } else {
        throw Exception('Failed to load class');
      }
    } catch (e) {
      print('Error fetching class: $e');
      throw Exception('Failed to load class: $e');
    }
  }

  // Create a new class
  Future<ClassModel> createClass(ClassModel classModel) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/classes'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authService.token}',
        },
        body: jsonEncode(classModel.toJson()),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ClassModel.fromJson(data);
      } else {
        throw Exception('Failed to create class');
      }
    } catch (e) {
      print('Error creating class: $e');
      throw Exception('Failed to create class: $e');
    }
  }

  // Update a class
  Future<ClassModel> updateClass(String id, ClassModel classModel) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/classes/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authService.token}',
        },
        body: jsonEncode(classModel.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ClassModel.fromJson(data);
      } else {
        throw Exception('Failed to update class');
      }
    } catch (e) {
      print('Error updating class: $e');
      throw Exception('Failed to update class: $e');
    }
  }

  // Delete a class
  Future<void> deleteClass(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/classes/$id'),
        headers: {'Authorization': 'Bearer ${_authService.token}'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete class');
      }
    } catch (e) {
      print('Error deleting class: $e');
      throw Exception('Failed to delete class: $e');
    }
  }
}
