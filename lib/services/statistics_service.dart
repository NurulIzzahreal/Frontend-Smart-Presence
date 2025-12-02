import 'package:frontend_smart_presence/models/attendance.dart';
import 'package:frontend_smart_presence/models/student.dart';
import 'package:frontend_smart_presence/models/class_model.dart';

class StatisticsService {
  // Calculate attendance statistics for dashboard
  Map<String, dynamic> calculateAttendanceStatistics(
    List<Attendance> attendanceRecords,
    List<Student> students,
    List<ClassModel> classes,
  ) {
    final totalRecords = attendanceRecords.length;
    final presentCount = attendanceRecords
        .where((r) => r.status.toLowerCase() == 'present')
        .length;
    final lateCount = attendanceRecords
        .where((r) => r.status.toLowerCase() == 'late')
        .length;
    final absentCount = attendanceRecords
        .where((r) => r.status.toLowerCase() == 'absent')
        .length;

    final attendanceRate = totalRecords > 0
        ? ((presentCount + lateCount) / totalRecords * 100)
        : 0.0;

    // Calculate average confidence score
    final avgConfidence = totalRecords > 0
        ? attendanceRecords.fold<double>(
                0.0,
                (sum, record) => sum + record.confidenceScore,
              ) /
              totalRecords
        : 0.0;

    // Group by class
    final Map<String, int> attendanceByClass = {};
    for (final record in attendanceRecords) {
      final student = students.firstWhere(
        (s) => s.id == record.studentId,
        orElse: () => Student(
          id: record.studentId,
          name: 'Unknown Student',
          email: '',
          studentId: record.studentId,
          className: '',
        ),
      );

      if (!attendanceByClass.containsKey(student.className)) {
        attendanceByClass[student.className] = 0;
      }
      attendanceByClass[student.className] =
          attendanceByClass[student.className]! + 1;
    }

    // Find students with abnormal attendance
    final Map<String, int> attendanceByStudent = {};
    for (final record in attendanceRecords) {
      if (!attendanceByStudent.containsKey(record.studentId)) {
        attendanceByStudent[record.studentId] = 0;
      }
      attendanceByStudent[record.studentId] =
          attendanceByStudent[record.studentId]! + 1;
    }

    // Students with low attendance (less than 70%)
    final List<String> lowAttendanceStudents = [];
    final threshold = (totalRecords * 0.7).toInt();
    for (final entry in attendanceByStudent.entries) {
      if (entry.value < threshold) {
        lowAttendanceStudents.add(entry.key);
      }
    }

    return {
      'totalRecords': totalRecords,
      'presentCount': presentCount,
      'lateCount': lateCount,
      'absentCount': absentCount,
      'attendanceRate': attendanceRate,
      'averageConfidence': avgConfidence,
      'attendanceByClass': attendanceByClass,
      'lowAttendanceStudents': lowAttendanceStudents,
      'classesCount': classes.length,
      'studentsCount': students.length,
    };
  }

  // Calculate daily attendance trend
  List<Map<String, dynamic>> calculateDailyTrend(
    List<Attendance> attendanceRecords,
  ) {
    final Map<String, List<Attendance>> dailyRecords = {};

    // Group records by date
    for (final record in attendanceRecords) {
      final dateKey =
          '${record.timestamp.year}-${record.timestamp.month}-${record.timestamp.day}';
      if (!dailyRecords.containsKey(dateKey)) {
        dailyRecords[dateKey] = [];
      }
      dailyRecords[dateKey]!.add(record);
    }

    // Calculate statistics for each day
    final List<Map<String, dynamic>> trendData = [];
    final sortedDates = dailyRecords.keys.toList()..sort();

    for (final date in sortedDates) {
      final records = dailyRecords[date]!;
      final total = records.length;
      final present = records
          .where((r) => r.status.toLowerCase() == 'present')
          .length;
      final late = records
          .where((r) => r.status.toLowerCase() == 'late')
          .length;
      final absent = records
          .where((r) => r.status.toLowerCase() == 'absent')
          .length;

      trendData.add({
        'date': date,
        'total': total,
        'present': present,
        'late': late,
        'absent': absent,
        'attendanceRate': total > 0 ? ((present + late) / total * 100) : 0.0,
      });
    }

    return trendData;
  }

  // Identify abnormal attendance patterns
  List<Map<String, dynamic>> identifyAbnormalPatterns(
    List<Attendance> attendanceRecords,
  ) {
    final List<Map<String, dynamic>> abnormalities = [];

    // Check for sudden drops in attendance
    final dailyTrend = calculateDailyTrend(attendanceRecords);

    if (dailyTrend.length >= 2) {
      for (int i = 1; i < dailyTrend.length; i++) {
        final currentRate = dailyTrend[i]['attendanceRate'] as double;
        final previousRate = dailyTrend[i - 1]['attendanceRate'] as double;

        // If attendance drops by more than 20%, flag as abnormal
        if (previousRate - currentRate > 20.0) {
          abnormalities.add({
            'type': 'attendance_drop',
            'date': dailyTrend[i]['date'],
            'message':
                'Attendance dropped from ${previousRate.toStringAsFixed(1)}% to ${currentRate.toStringAsFixed(1)}%',
            'severity': 'high',
          });
        }
      }
    }

    // Check for high lateness rate
    final totalRecords = attendanceRecords.length;
    final lateCount = attendanceRecords
        .where((r) => r.status.toLowerCase() == 'late')
        .length;
    final latenessRate = totalRecords > 0
        ? (lateCount / totalRecords * 100)
        : 0.0;

    if (latenessRate > 30.0) {
      abnormalities.add({
        'type': 'high_lateness',
        'message': 'High lateness rate: ${latenessRate.toStringAsFixed(1)}%',
        'severity': 'medium',
      });
    }

    return abnormalities;
  }
}
