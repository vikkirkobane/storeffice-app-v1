// This file is kept for backward compatibility
// Use lib/models/user_profile.dart for the complete user model
class AppUser {
  final String id;
  final String email;
  final String role;

  AppUser({required this.id, required this.email, required this.role});

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'Customer',
    );
  }
}
