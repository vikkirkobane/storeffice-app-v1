class UserProfile {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? profilePhoto;
  final List<String> roles;
  final List<String> deviceTokens;
  final Map<String, dynamic> preferences;
  final DateTime? lastSeen;
  final String? appVersion;
  final String? platform;
  final bool isVerified;
  final bool isActive;
  final bool isOnline;

  UserProfile({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.profilePhoto,
    this.roles = const ['customer'],
    this.deviceTokens = const [],
    this.preferences = const {},
    this.lastSeen,
    this.appVersion,
    this.platform,
    this.isVerified = false,
    this.isActive = true,
    this.isOnline = false,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id']?.toString() ?? '',
      email: map['email'] ?? '',
      firstName: map['first_name'],
      lastName: map['last_name'],
      phone: map['phone'],
      profilePhoto: map['profile_photo'],
      roles: List<String>.from(map['roles'] ?? ['customer']),
      deviceTokens: List<String>.from(map['device_tokens'] ?? []),
      preferences: Map<String, dynamic>.from(map['preferences'] ?? {}),
      lastSeen: map['last_seen'] != null ? DateTime.parse(map['last_seen']) : null,
      appVersion: map['app_version'],
      platform: map['platform'],
      isVerified: map['is_verified'] ?? false,
      isActive: map['is_active'] ?? true,
      isOnline: map['is_online'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'profile_photo': profilePhoto,
      'roles': roles,
      'device_tokens': deviceTokens,
      'preferences': preferences,
      'last_seen': lastSeen?.toIso8601String(),
      'app_version': appVersion,
      'platform': platform,
      'is_verified': isVerified,
      'is_active': isActive,
      'is_online': isOnline,
    };
  }
}