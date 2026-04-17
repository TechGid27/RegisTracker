enum UserRole {
  admin,
  staff,
  student;

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'staff':
        return UserRole.staff;
      case 'admin':
        return UserRole.admin;
      case 'student':
      default:
        return UserRole.student;
    }
  }
}

class UserModel {
  final int? id;
  final String email;
  final String firstName;
  final String lastName;
  final UserRole role;
  final String? studentId;
  final String? department;

  String get fullName => '$firstName $lastName';

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.studentId,
    this.department,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      role: UserRole.fromString(json['role'] ?? 'student'),
      studentId: json['studentId'],
      department: json['department'],
    );
  }
}
