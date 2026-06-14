/// Booking model — ported from QCUT Kotlin Booking.kt
class Booking {
  final String id;
  final String tenantId;
  final String customerName;
  final String phoneNumber;
  final String barberId;
  final String barberName;
  final String date; // YYYY-MM-DD
  final String timeSlot; // HH:MM
  final DateTime? startTime;
  final DateTime? endTime;
  final String status; // confirmed, completed, cancelled, no-show
  final String serviceType;
  final String bookingCode;
  final int durationMin;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Booking({
    this.id = '',
    this.tenantId = '',
    this.customerName = '',
    this.phoneNumber = '',
    this.barberId = '',
    this.barberName = '',
    this.date = '',
    this.timeSlot = '',
    this.startTime,
    this.endTime,
    this.status = 'confirmed',
    this.serviceType = '',
    this.bookingCode = '',
    this.durationMin = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory Booking.fromMap(Map<String, dynamic> map, String id) {
    return Booking(
      id: id,
      tenantId: map['tenantId'] ?? '',
      customerName: map['customerName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      barberId: map['barberId'] ?? '',
      barberName: map['barberName'] ?? '',
      date: map['date'] ?? '',
      timeSlot: map['timeSlot'] ?? '',
      startTime: map['startTime']?.toDate(),
      endTime: map['endTime']?.toDate(),
      status: map['status'] ?? 'confirmed',
      serviceType: map['serviceType'] ?? '',
      bookingCode: map['bookingCode'] ?? '',
      durationMin: map['durationMin'] ?? 0,
      createdAt: map['createdAt']?.toDate(),
      updatedAt: map['updatedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tenantId': tenantId,
      'customerName': customerName,
      'phoneNumber': phoneNumber,
      'barberId': barberId,
      'barberName': barberName,
      'date': date,
      'timeSlot': timeSlot,
      'startTime': startTime,
      'endTime': endTime,
      'status': status,
      'serviceType': serviceType,
      'bookingCode': bookingCode,
      'durationMin': durationMin,
      'createdAt': createdAt,
      'updatedAt': DateTime.now(),
    };
  }
}
