import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qcut_flutter/domain/models/booking.dart';

void main() {
  test('Booking fromMap parses date and timeSlot', () {
    final createdAt = DateTime(2024, 1, 15, 10, 0, 0);
    final booking = Booking.fromMap({
      'customerName': 'Ravi',
      'customerPhone': '+919876543210',
      'serviceId': 'svc1',
      'date': '2024-01-20',
      'timeSlot': '10:30',
      'status': 'confirmed',
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(createdAt),
    }, 'b1');
    expect(booking.id, 'b1');
    expect(booking.date, '2024-01-20');
    expect(booking.timeSlot, '10:30');
    expect(booking.status, BookingStatus.confirmed);
    expect(booking.serviceId, 'svc1');
    expect(booking.customerName, 'Ravi');
    expect(booking.customerPhone, '+919876543210');
    expect(booking.createdAt, createdAt);
  });

  test('Booking toMap round-trips through fromMap', () {
    final createdAt = DateTime(2024, 2, 1, 9, 30, 0);
    final updatedAt = DateTime(2024, 2, 2, 11, 0, 0);
    final original = Booking(
      id: 'b2',
      customerName: 'Anita',
      customerPhone: '+919800001111',
      serviceId: 'svc2',
      staffId: 'staff1',
      date: '2024-02-10',
      timeSlot: '14:00',
      status: BookingStatus.completed,
      tokenId: 'tok9',
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
    final map = original.toMap();
    final restored = Booking.fromMap(map, 'b2');
    expect(restored.id, 'b2');
    expect(restored.customerName, 'Anita');
    expect(restored.customerPhone, '+919800001111');
    expect(restored.serviceId, 'svc2');
    expect(restored.staffId, 'staff1');
    expect(restored.date, '2024-02-10');
    expect(restored.timeSlot, '14:00');
    expect(restored.status, BookingStatus.completed);
    expect(restored.tokenId, 'tok9');
    expect(restored.createdAt, createdAt);
    expect(restored.updatedAt, updatedAt);
  });

  test('Booking fromMap defaults status to confirmed when unknown', () {
    final booking = Booking.fromMap({
      'customerName': 'X',
      'customerPhone': 'Y',
      'serviceId': 's',
      'date': '2024-01-01',
      'timeSlot': '09:00',
      'status': 'bogus',
    }, 'b3');
    expect(booking.status, BookingStatus.confirmed);
  });

  test('Booking copyWith updates status, tokenId and updatedAt only', () {
    final createdAt = DateTime(2024, 3, 1, 8, 0, 0);
    final updatedAt = DateTime(2024, 3, 1, 8, 0, 0);
    final original = Booking(
      id: 'b4',
      customerName: 'Sam',
      customerPhone: '+91',
      serviceId: 'svc',
      date: '2024-03-05',
      timeSlot: '11:00',
      status: BookingStatus.confirmed,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
    final newUpdatedAt = DateTime(2024, 3, 2, 9, 0, 0);
    final updated = original.copyWith(
      status: BookingStatus.cancelled,
      tokenId: 'tok1',
      updatedAt: newUpdatedAt,
    );
    expect(updated.id, 'b4');
    expect(updated.customerName, 'Sam');
    expect(updated.date, '2024-03-05');
    expect(updated.timeSlot, '11:00');
    expect(updated.status, BookingStatus.cancelled);
    expect(updated.tokenId, 'tok1');
    expect(updated.updatedAt, newUpdatedAt);
    expect(updated.createdAt, createdAt);
  });
}
