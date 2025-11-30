class Student {
  final String id;
  final String name;
  final String email;
  final String studentId;
  final String className;
  final String? faceEncoding; // For face recognition

  Student({
    required this.id,
    required this.name,
    required this.email,
    required this.studentId,
    required this.className,
    this.faceEncoding,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      studentId: json['studentId'] as String,
      className: json['className'] as String,
      faceEncoding: json['faceEncoding'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'studentId': studentId,
      'className': className,
      'faceEncoding': faceEncoding,
    };
  }
}
