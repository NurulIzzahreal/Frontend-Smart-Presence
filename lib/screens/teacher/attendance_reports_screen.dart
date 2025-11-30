import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend_smart_presence/models/attendance.dart';
import 'package:frontend_smart_presence/models/student.dart';
import 'package:frontend_smart_presence/models/class_model.dart';
import 'package:frontend_smart_presence/services/attendance_service.dart';
import 'package:frontend_smart_presence/services/student_service.dart';
import 'package:frontend_smart_presence/services/class_service.dart';
import 'package:frontend_smart_presence/services/report_service.dart';
import 'package:printing/printing.dart';
import 'package:open_file/open_file.dart';

class AttendanceReportsScreen extends StatefulWidget {
  const AttendanceReportsScreen({super.key});

  @override
  State<AttendanceReportsScreen> createState() =>
      _AttendanceReportsScreenState();
}

class _AttendanceReportsScreenState extends State<AttendanceReportsScreen> {
  List<ClassModel> _classes = [];
  List<Student> _students = [];
  List<Attendance> _attendanceRecords = [];
  String? _selectedClassId;
  DateTimeRange? _dateRange;
  bool _isLoading = false;
  Map<String, dynamic> _summaryStats = {};

  @override
  void initState() {
    super.initState();
    _loadClasses();
    _setDateRangeToCurrentMonth();
  }

  void _setDateRangeToCurrentMonth() {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);
    setState(() {
      _dateRange = DateTimeRange(start: firstDay, end: lastDay);
    });
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

  Future<void> _loadStudents() async {
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
    }
  }

  Future<void> _loadAttendanceData() async {
    if (_selectedClassId == null || _dateRange == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final attendanceService = AttendanceService();
      final attendance = await attendanceService.getAttendanceByClass(
        _selectedClassId!,
      );

      // Filter by date range
      final filteredAttendance = attendance.where((record) {
        return record.timestamp.isAfter(
              _dateRange!.start.subtract(const Duration(days: 1)),
            ) &&
            record.timestamp.isBefore(
              _dateRange!.end.add(const Duration(days: 1)),
            );
      }).toList();

      // Load students if not already loaded
      if (_students.isEmpty) {
        await _loadStudents();
      }

      setState(() {
        _attendanceRecords = filteredAttendance;
      });

      // Generate summary statistics
      final reportService = ReportService();
      final stats = reportService.generateSummaryStatistics(
        filteredAttendance,
        _students,
      );
      setState(() {
        _summaryStats = stats;
      });
    } catch (e) {
      print('Error loading attendance data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load attendance data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _dateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
      _loadAttendanceData();
    }
  }

  Future<void> _exportToCSV() async {
    if (_selectedClassId == null ||
        _attendanceRecords.isEmpty ||
        _dateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a class and date range first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final selectedClass = _classes.firstWhere(
        (c) => c.id == _selectedClassId,
      );
      final reportService = ReportService();
      final csvContent = await reportService.generateCSVReport(
        _attendanceRecords,
        _students,
        selectedClass,
        _dateRange!.start,
        _dateRange!.end,
      );

      final fileName =
          'attendance_report_${selectedClass.name}_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = await reportService.saveCSVReport(csvContent, fileName);

      // Open the file
      final result = await OpenFile.open(file.path);
      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open file: ${result.message}'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CSV report saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error exporting to CSV: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export CSV: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _exportToPDF() async {
    if (_selectedClassId == null ||
        _attendanceRecords.isEmpty ||
        _dateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a class and date range first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final selectedClass = _classes.firstWhere(
        (c) => c.id == _selectedClassId,
      );
      final reportService = ReportService();
      final pdfFile = await reportService.generatePDFReport(
        _attendanceRecords,
        _students,
        selectedClass,
        _dateRange!.start,
        _dateRange!.end,
      );

      // Share or open the PDF
      await Printing.sharePdf(
        bytes: await pdfFile.readAsBytes(),
        filename:
            'attendance_report_${selectedClass.name}_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF report generated and shared successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error exporting to PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Reports'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.download), onPressed: _exportToCSV),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _exportToPDF,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Card(
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Class selection
                  DropdownButtonFormField<String>(
                    value: _selectedClassId,
                    decoration: const InputDecoration(
                      labelText: 'Select Class',
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
                    onChanged: (value) {
                      setState(() {
                        _selectedClassId = value;
                      });
                      if (value != null) {
                        _loadAttendanceData();
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Date range selection
                  ListTile(
                    title: const Text('Date Range'),
                    subtitle: _dateRange != null
                        ? Text(
                            '${_formatDate(_dateRange!.start)} - ${_formatDate(_dateRange!.end)}',
                          )
                        : const Text('Select date range'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: _selectDateRange,
                  ),
                ],
              ),
            ),
          ),

          // Summary statistics
          if (_summaryStats.isNotEmpty)
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatCard(
                          'Total',
                          _summaryStats['totalRecords'].toString(),
                          Icons.list,
                        ),
                        _buildStatCard(
                          'Present',
                          _summaryStats['presentCount'].toString(),
                          Icons.check_circle,
                          Colors.green,
                        ),
                        _buildStatCard(
                          'Late',
                          _summaryStats['lateCount'].toString(),
                          Icons.access_time,
                          Colors.orange,
                        ),
                        _buildStatCard(
                          'Absent',
                          _summaryStats['absentCount'].toString(),
                          Icons.cancel,
                          Colors.red,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatCard(
                          'Attendance Rate',
                          '${_summaryStats['attendanceRate'].toStringAsFixed(1)}%',
                          Icons.percent,
                        ),
                        _buildStatCard(
                          'Avg Confidence',
                          '${(_summaryStats['averageConfidence'] * 100).toStringAsFixed(1)}%',
                          Icons.bar_chart,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Attendance records
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _attendanceRecords.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.analytics_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'No attendance records found',
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Select a class and date range to view reports',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _attendanceRecords.length,
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
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon, [
    Color? color,
  ]) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Icon(icon, color: color ?? Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
