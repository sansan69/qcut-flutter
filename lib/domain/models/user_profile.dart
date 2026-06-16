import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { customer, provider, attendant, platformAdmin }

class UserProfile {
  final String uid;
  final String? email;
  final String? phone;
  final UserRole role;
  final String? tenantId;
  final String displayName;
  final List<String> fcmTokens;
  final DateTime? createdAt;

  const UserProfile({
    required this.uid,
    this.email,
    this.phone,
    required this.role,
    this.tenantId,
    required this.displayName,
    this.fcmTokens = const [],
    this.createdAt,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map, String uid) {
    return UserProfile(
      uid: uid,
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      role: _parseRole(map['role'] as String? ?? 'customer'),
      tenantId: map['tenantId'] as String?,
      displayName: map['displayName'] as String? ?? '',
      fcmTokens: List<String>.from(map['fcmTokens'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'email': email,
        'phone': phone,
        'role': role.name,
        'tenantId': tenantId,
        'displayName': displayName,
        'fcmTokens': fcmTokens,
        'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      };

  static UserRole _parseRole(String value) =>
      UserRole.values.firstWhere((r) => r.name == value, orElse: () => UserRole.customer);
}
