/// Token queue entry — ported from QCUT Kotlin TokenEntry.kt
class TokenEntry {
  final String id;
  final int tokenNumber;
  final String name;
  final String phone;
  final String status; // waiting, serving, completed, no-show, cancelled
  final String? staffId;
  final String? staffName;
  final String date; // YYYY-MM-DD
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TokenEntry({
    this.id = '',
    this.tokenNumber = 0,
    this.name = '',
    this.phone = '',
    this.status = 'waiting',
    this.staffId,
    this.staffName,
    this.date = '',
    this.createdAt,
    this.updatedAt,
  });

  factory TokenEntry.fromMap(Map<String, dynamic> map, String id) {
    return TokenEntry(
      id: id,
      tokenNumber: map['tokenNumber'] ?? 0,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      status: map['status'] ?? 'waiting',
      staffId: map['staffId'],
      staffName: map['staffName'],
      date: map['date'] ?? '',
      createdAt: map['createdAt']?.toDate(),
      updatedAt: map['updatedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tokenNumber': tokenNumber,
      'name': name,
      'phone': phone,
      'status': status,
      'staffId': staffId,
      'staffName': staffName,
      'date': date,
      'createdAt': createdAt,
      'updatedAt': DateTime.now(),
    };
  }

  TokenEntry copyWith({
    String? id,
    int? tokenNumber,
    String? name,
    String? phone,
    String? status,
    String? staffId,
    String? staffName,
    String? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TokenEntry(
      id: id ?? this.id,
      tokenNumber: tokenNumber ?? this.tokenNumber,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
