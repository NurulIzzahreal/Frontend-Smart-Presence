import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:frontend_smart_presence/models/attendance.dart';
import 'package:frontend_smart_presence/models/student.dart';
import 'package:frontend_smart_presence/models/class_model.dart';

class ReportService {
  // Generate CSV report
  Future<String> generateCSVReport(
    List<Attendance> attendanceRecords,
    List<Student> students,
    ClassModel classModel,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final StringBuffer csvBuffer = StringBuffer();
    
    // Add CSV header
    csvBuffer.writeln('Student ID,Student Name,Date,Status,Confidence Score');
    
    // Add attendance data
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
      
      csvBuffer.writeln(
        '${student.studentId},${student.name},${record.timestamp.toIso8601String()},${record.status},${record.confidenceScore.toStringAsFixed(2)}',
      );
    }
    
    return csvBuffer.toString();
  }
  
  // Generate PDF report
  Future<File> generatePDFReport(
    List<Attendance> attendanceRecords,
    List<Student> students,
    ClassModel classModel,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final pdf = pw.Document();
    
    // Group attendance by student
    final Map<String, List<Attendance>> attendanceByStudent = {};
    for (final record in attendanceRecords) {
      if (!attendanceByStudent.containsKey(record.studentId)) {
        attendanceByStudent[record.studentId] = [];
      }
      attendanceByStudent[record.studentId]!.add(record);
    }
    
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Attendance Report',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Class: ${classModel.name}'),
                      pw.Text('Schedule: ${classModel.schedule}'),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Period: ${_formatDate(startDate)} to ${_formatDate(endDate)}'),
                      pw.Text('Generated: ${_formatDate(DateTime.now())}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ['Student ID', 'Student Name', 'Present', 'Late', 'Absent', 'Attendance Rate'],
                data: [
                  for (final entry in attendanceByStudent.entries)
                    _buildStudentAttendanceRow(
                      entry.key,
                      entry.value,
                      students,
                      attendanceRecords.length,
                    ),
                ],
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                cellAlignment: pw.Alignment.centerLeft,
                cellStyle: const pw.TextStyle(
                  fontSize: 10,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Detailed Attendance Records',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: ['Date', 'Student', 'Status', 'Confidence'],
                data: [
                  for (final record in attendanceRecords)
                    [
                      _formatDate(record.timestamp),
                      _getStudentName(record.studentId, students),
                      record.status,
                      '${(record.confidenceScore * 100).toStringAsFixed(1)}%',
                    ],
                ],
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                cellAlignment: pw.Alignment.centerLeft,
                cellStyle: const pw.TextStyle(
                  fontSize: 8,
                ),
              ),
            ],
          );
        },
      ),
    );
    
    // Save PDF to file
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/attendance_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    
    return file;
  }
  
  // Helper method to build student attendance row
  List<String> _buildStudentAttendanceRow(
    String studentId,
    List<Attendance> records,
    List<Student> students,
    int totalRecords,
  ) {
    final student = students.firstWhere(
      (s) => s.id == studentId,
      orElse: () => Student(
        id: studentId,
        name: 'Unknown Student',
        email: '',
        studentId: studentId,
        className: '',
      ),
    );
    
    final presentCount = records.where((r) => r.status.toLowerCase() == 'present').length;
    final lateCount = records.where((r) => r.status.toLowerCase() == 'late').length;
    final absentCount = records.where((r) => r.status.toLowerCase() == 'absent').length;
    
    final attendanceRate = totalRecords > 0 
      ? ((presentCount + lateCount) / totalRecords * 100).toStringAsFixed(1) 
      : '0.0';
    
    return [
      student.studentId,
      student.name,
      presentCount.toString(),
      lateCount.toString(),
      absentCount.toString(),
      '$attendanceRate%',
    ];
  }
  
  // Helper method to get student name
  String _getStudentName(String studentId, List<Student> students) {
    final student = students.firstWhere(
      (s) => s.id == studentId,
      orElse: () => Student(
        id: studentId,
        name: 'Unknown Student',
        email: '',
        studentId: studentId,
        className: '',
      ),
    );
    return student.name;
  }
  
  // Helper method to format date
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  // Save CSV report to file
  Future<File> saveCSVReport(String csvContent, String fileName) async {
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/$fileName.csv');
    await file.writeAsString(csvContent);
    return file;
  }
  
  // Generate summary statistics
  Map<String, dynamic> generateSummaryStatistics(
    List<Attendance> attendanceRecords,
    List<Student> students,
  ) {
    final totalRecords = attendanceRecords.length;
    final presentCount = attendanceRecords.where((r) => r.status.toLowerCase() == 'present').length;
    final lateCount = attendanceRecords.where((r) => r.status.toLowerCase() == 'late').length;
    final absentCount = attendanceRecords.where((r) => r.status.toLowerCase() == 'absent').length;
    
    final attendanceRate = totalRecords > 0 
      ? ((presentCount + lateCount) / totalRecords * 100) 
      : 0.0;
    
    // Calculate average confidence score
    final avgConfidence = totalRecords > 0
      ? attendanceRecords.fold<double>(0.0, (sum, record) => sum + record.confidenceScore) / totalRecords
      : 0.0;
    
    return {
      'totalRecords': totalRecords,
      'presentCount': presentCount,
      'lateCount': lateCount,
      'absentCount': absentCount,
      'attendanceRate': attendanceRate,
      'averageConfidence': avgConfidence,
    };
  }
}