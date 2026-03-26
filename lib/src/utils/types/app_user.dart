import 'app_role.dart';

class AppUser {
  const AppUser({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
  });

  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final AppRole role;

  String get fullName => '$firstName $lastName'.trim();

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role': role.value,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: '${map['uid'] ?? ''}',
      firstName: '${map['firstName'] ?? ''}',
      lastName: '${map['lastName'] ?? ''}',
      email: '${map['email'] ?? ''}',
      role: AppRole.fromString('${map['role'] ?? 'customer'}'),
    );
  }

  AppUser copyWith({
    String? firstName,
    String? lastName,
    String? email,
    AppRole? role,
  }) {
    return AppUser(
      uid: uid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      role: role ?? this.role,
    );
  }
}
