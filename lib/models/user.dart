class User {
  final String id;
  final String name;
  final String email;
  final String role; // admin, teacher, student
  final String? studentId; // Only for students
  final String? className; // Only for students

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.studentId,
    this.className,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      studentId: json['studentId'] as String?,
      className: json['className'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'studentId': studentId,
      'className': className,
    };
  }
}
