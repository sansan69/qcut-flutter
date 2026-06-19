import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qcut_flutter/data/services/functions_service.dart';
import 'package:qcut_flutter/domain/models/booking.dart';

class BookingRepository {
  final FunctionsService _functions;
  final FirebaseFirestore _firestore;

  BookingRepository(this._functions, this._firestore);

  Stream<List<Booking>> bookingsForDate(String tenantId, String date) {
    return _firestore
        .collection('tenants')
        .doc(tenantId)
        .collection('bookings')
        .where('date', isEqualTo: date)
        .orderBy('timeSlot')
        .snapshots()
        .map((snap) => snap.docs.map((d) => Booking.fromMap(d.data(), d.id)).toList());
  }

  Future<List<String>> availableSlots({
    required String tenantId,
    required String serviceId,
    required String date,
    String? staffId,
  }) async {
    final result = await _functions.call(FunctionsService.getAvailableSlots, {
      'tenantId': tenantId,
      'serviceId': serviceId,
      'date': date,
      if (staffId != null) 'staffId': staffId,
    });
    return List<String>.from(result['slots'] as List);
  }

  Future<Booking> createBooking({
    required String tenantId,
    required String customerName,
    required String customerPhone,
    required String serviceId,
    required String date,
    required String timeSlot,
    String? staffId,
  }) async {
    final result = await _functions.call(FunctionsService.createBooking, {
      'tenantId': tenantId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'serviceId': serviceId,
      'date': date,
      'timeSlot': timeSlot,
      if (staffId != null) 'staffId': staffId,
    });
    return Booking.fromMap(result['entry'] as Map<String, dynamic>, result['id'] as String);
  }

  Future<Booking> cancelBooking(String tenantId, String bookingId) async {
    final result = await _functions.call(FunctionsService.cancelBooking, {
      'tenantId': tenantId,
      'bookingId': bookingId,
    });
    return Booking.fromMap(result['entry'] as Map<String, dynamic>, result['id'] as String);
  }

  Future<Booking> convertToToken(String tenantId, String bookingId) async {
    final result = await _functions.call(FunctionsService.convertBookingToToken, {
      'tenantId': tenantId,
      'bookingId': bookingId,
    });
    return Booking.fromMap(result['entry'] as Map<String, dynamic>, result['id'] as String);
  }
}
