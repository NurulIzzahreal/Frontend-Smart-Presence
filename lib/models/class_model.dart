class ClassModel {
  final String id;
  final String name;
  final String teacherId;
  final String schedule;

  ClassModel({
    required this.id,
    required this.name,
    required this.teacherId,
    required this.schedule,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'] as String,
      name: json['name'] as String,
      teacherId: json['teacherId'] as String,
      schedule: json['schedule'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'teacherId': teacherId,
      'schedule': schedule,
    };
  }
}
