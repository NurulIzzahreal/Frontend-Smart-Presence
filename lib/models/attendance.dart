class Attendance {
  final String id;
  final String studentId;
  final String classId;
  final DateTime timestamp;
  final double confidenceScore;
  final String status; // present, late, absent

  Attendance({
    required this.id,
    required this.studentId,
    required this.classId,
    required this.timestamp,
    required this.confidenceScore,
    required this.status,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      classId: json['classId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      confidenceScore: (json['confidenceScore'] as num).toDouble(),
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'classId': classId,
      'timestamp': timestamp.toIso8601String(),
      'confidenceScore': confidenceScore,
      'status': status,
    };
  }
}
