import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus { confirmed, completed, cancelled, noShow }

class Booking {
  final String id;
  final String customerName;
  final String customerPhone;
  final String serviceId;
  final String? staffId;
  final String date;
  final String timeSlot;
  final BookingStatus status;
  final String? tokenId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Booking({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.serviceId,
    this.staffId,
    required this.date,
    required this.timeSlot,
    required this.status,
    this.tokenId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Booking.fromMap(Map<String, dynamic> map, String id) {
    return Booking(
      id: id,
      customerName: map['customerName'] as String? ?? '',
      customerPhone: map['customerPhone'] as String? ?? '',
      serviceId: map['serviceId'] as String? ?? '',
      staffId: map['staffId'] as String?,
      date: map['date'] as String? ?? '',
      timeSlot: map['timeSlot'] as String? ?? '',
      status: _parseStatus(map['status'] as String? ?? 'confirmed'),
      tokenId: map['tokenId'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerName': customerName,
      'customerPhone': customerPhone,
      'serviceId': serviceId,
      'staffId': staffId,
      'date': date,
      'timeSlot': timeSlot,
      'status': status.name,
      'tokenId': tokenId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static BookingStatus _parseStatus(String value) => BookingStatus.values.firstWhere(
        (s) => s.name == value,
        orElse: () => BookingStatus.confirmed,
      );

  Booking copyWith({BookingStatus? status, String? tokenId, DateTime? updatedAt}) => Booking(
        id: id,
        customerName: customerName,
        customerPhone: customerPhone,
        serviceId: serviceId,
        staffId: staffId,
        date: date,
        timeSlot: timeSlot,
        status: status ?? this.status,
        tokenId: tokenId ?? this.tokenId,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
