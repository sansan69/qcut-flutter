import 'package:cloud_firestore/cloud_firestore.dart';

enum TokenStatus { waiting, called, serving, completed, noShow, cancelled }

class TokenEntry {
  final String id;
  final int tokenNumber;
  final TokenStatus status;
  final String customerName;
  final String customerPhone;
  final String? staffId;
  final String? serviceId;
  final String? bookingId;
  final DateTime issuedAt;
  final DateTime? calledAt;
  final DateTime? completedAt;
  final DateTime? noShowAt;
  final int estimatedWaitMinutes;
  final String source;

  TokenEntry({
    required this.id,
    required this.tokenNumber,
    required this.status,
    required this.customerName,
    required this.customerPhone,
    this.staffId,
    this.serviceId,
    this.bookingId,
    required this.issuedAt,
    this.calledAt,
    this.completedAt,
    this.noShowAt,
    this.estimatedWaitMinutes = 0,
    this.source = 'walk_in',
  });

  factory TokenEntry.fromMap(Map<String, dynamic> map, String id) {
    return TokenEntry(
      id: id,
      tokenNumber: map['tokenNumber'] as int? ?? 0,
      status: _parseStatus(map['status'] as String? ?? 'waiting'),
      customerName: map['customerName'] as String? ?? '',
      customerPhone: map['customerPhone'] as String? ?? '',
      staffId: map['staffId'] as String?,
      serviceId: map['serviceId'] as String?,
      bookingId: map['bookingId'] as String?,
      issuedAt: (map['issuedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      calledAt: (map['calledAt'] as Timestamp?)?.toDate(),
      completedAt: (map['completedAt'] as Timestamp?)?.toDate(),
      noShowAt: (map['noShowAt'] as Timestamp?)?.toDate(),
      estimatedWaitMinutes: map['estimatedWaitMinutes'] as int? ?? 0,
      source: map['source'] as String? ?? 'walk_in',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tokenNumber': tokenNumber,
      'status': status.name,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'staffId': staffId,
      'serviceId': serviceId,
      'bookingId': bookingId,
      'issuedAt': Timestamp.fromDate(issuedAt),
      'calledAt': calledAt != null ? Timestamp.fromDate(calledAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'noShowAt': noShowAt != null ? Timestamp.fromDate(noShowAt!) : null,
      'estimatedWaitMinutes': estimatedWaitMinutes,
      'source': source,
    };
  }

  static TokenStatus _parseStatus(String value) => TokenStatus.values.firstWhere(
        (s) => s.name == value,
        orElse: () => TokenStatus.waiting,
      );

  TokenEntry copyWith({TokenStatus? status, DateTime? calledAt, DateTime? completedAt, DateTime? noShowAt, int? estimatedWaitMinutes}) =>
      TokenEntry(
        id: id,
        tokenNumber: tokenNumber,
        status: status ?? this.status,
        customerName: customerName,
        customerPhone: customerPhone,
        staffId: staffId,
        serviceId: serviceId,
        bookingId: bookingId,
        issuedAt: issuedAt,
        calledAt: calledAt ?? this.calledAt,
        completedAt: completedAt ?? this.completedAt,
        noShowAt: noShowAt ?? this.noShowAt,
        estimatedWaitMinutes: estimatedWaitMinutes ?? this.estimatedWaitMinutes,
        source: source,
      );
}
