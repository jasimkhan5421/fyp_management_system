class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;        // 'student' or 'supervisor'
  final String department;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.department,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid:        map['uid']        ?? '',
      name:       map['name']       ?? '',
      email:      map['email']      ?? '',
      role:       map['role']       ?? 'student',
      department: map['department'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'uid':        uid,
    'name':       name,
    'email':      email,
    'role':       role,
    'department': department,
  };
}