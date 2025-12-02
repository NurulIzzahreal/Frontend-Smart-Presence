import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:frontend_smart_presence/models/attendance.dart';
import 'package:frontend_smart_presence/services/auth_service.dart';
import 'package:frontend_smart_presence/services/notification_service.dart';
import 'package:frontend_smart_presence/services/parent_notification_service.dart';

class AttendanceService {
  static const String baseUrl = 'http://localhost:8000/api';

  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();
  final ParentNotificationService _parentNotificationService =
      ParentNotificationService();

  // Get all attendance records
  Future<List<Attendance>> getAllAttendance() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/attendance'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authService.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Attendance.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load attendance records');
      }
    } catch (e) {
      print('Error fetching attendance records: $e');
      throw Exception('Failed to load attendance records: $e');
    }
  }

  // Get attendance by class ID
  Future<List<Attendance>> getAttendanceByClass(String classId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/attendance/class/$classId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authService.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Attendance.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load attendance records');
      }
    } catch (e) {
      print('Error fetching attendance records: $e');
      throw Exception('Failed to load attendance records: $e');
    }
  }

  // Get attendance by student ID
  Future<List<Attendance>> getAttendanceByStudent(String studentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/attendance/student/$studentId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authService.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Attendance.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load attendance records');
      }
    } catch (e) {
      print('Error fetching attendance records: $e');
      throw Exception('Failed to load attendance records: $e');
    }
  }

  // Mark attendance using face recognition
  Future<Attendance> markAttendanceWithFaceRecognition(
    String studentId,
    String classId,
    Uint8List imageBytes,
  ) async {
    try {
      // Create multipart request for image upload
      final uri = Uri.parse('$baseUrl/attendance/face-recognition');
      final request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer ${_authService.token}';

      // Add image file
      final multipartFile = http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: 'attendance_image.jpg',
      );

      request.files.add(multipartFile);

      // Add other fields
      request.fields['studentId'] = studentId;
      request.fields['classId'] = classId;

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(responseBody);
        final attendance = Attendance.fromJson(data);

        // Check if attendance is absent and send parent notification
        if (attendance.status.toLowerCase() == 'absent') {
          // In a real implementation, you would get parent details from the backend
          _parentNotificationService.sendAbsenceNotification(
            parentName: 'Parent', // This should come from student/parent data
            studentName: 'Student', // This should come from student data
            absenceDate: attendance.timestamp,
          );
        }

        return attendance;
      } else {
        throw Exception('Failed to mark attendance: ${response.statusCode}');
      }
    } catch (e) {
      print('Error marking attendance: $e');
      throw Exception('Failed to mark attendance: $e');
    }
  }

  // Mark attendance manually (for teachers)
  Future<Attendance> markAttendanceManually(
    String studentId,
    String classId,
    String status,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/attendance/manual'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authService.token}',
        },
        body: jsonEncode({
          'studentId': studentId,
          'classId': classId,
          'status': status,
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final attendance = Attendance.fromJson(data);

        // Check if attendance is absent and send parent notification
        if (status.toLowerCase() == 'absent') {
          // In a real implementation, you would get parent details from the backend
          _parentNotificationService.sendAbsenceNotification(
            parentName: 'Parent', // This should come from student/parent data
            studentName: 'Student', // This should come from student data
            absenceDate: attendance.timestamp,
          );
        }

        return attendance;
      } else {
        throw Exception('Failed to mark attendance');
      }
    } catch (e) {
      print('Error marking attendance: $e');
      throw Exception('Failed to mark attendance: $e');
    }
  }

  // Get attendance statistics
  Future<Map<String, dynamic>> getAttendanceStatistics(String classId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/attendance/statistics/$classId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authService.token}',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load attendance statistics');
      }
    } catch (e) {
      print('Error fetching attendance statistics: $e');
      throw Exception('Failed to load attendance statistics: $e');
    }
  }

  // Check for abnormal attendance patterns and notify teachers
  Future<void> checkAbnormalAttendancePatterns(
    List<Attendance> attendanceRecords,
  ) async {
    try {
      // Simple check: if more than 30% of students are absent, it's abnormal
      final totalRecords = attendanceRecords.length;
      final absentRecords = attendanceRecords
          .where((r) => r.status.toLowerCase() == 'absent')
          .length;
      final absentPercentage = totalRecords > 0
          ? (absentRecords / totalRecords * 100)
          : 0;

      if (absentPercentage > 30) {
        await _notificationService.sendAbnormalAttendanceNotification(
          'High absence rate detected: ${absentPercentage.toStringAsFixed(1)}%',
          absentRecords,
        );
      }
    } catch (e) {
      print('Error checking abnormal attendance patterns: $e');
    }
  }
}
