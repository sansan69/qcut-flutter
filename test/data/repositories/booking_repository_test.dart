import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qcut_flutter/data/repositories/booking_repository.dart';
import 'package:qcut_flutter/data/services/functions_service.dart';
import 'package:qcut_flutter/domain/models/booking.dart';

class MockFunctionsService extends Mock implements FunctionsService {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

void main() {
  test('createBooking calls createBooking function with correct params and parses result', () async {
    final functions = MockFunctionsService();
    final firestore = MockFirebaseFirestore();
    final repo = BookingRepository(functions, firestore);
    when(() => functions.call(FunctionsService.createBooking, any())).thenAnswer(
      (_) async => {
        'id': 'book1',
        'entry': {
          'customerName': 'Ravi',
          'customerPhone': '+919876543210',
          'serviceId': 'svc1',
          'staffId': 'staff1',
          'date': '2024-01-20',
          'timeSlot': '10:30',
          'status': 'confirmed',
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 15, 10, 0, 0)),
          'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 15, 10, 0, 0)),
        },
      },
    );

    final result = await repo.createBooking(
      tenantId: 'ten1',
      customerName: 'Ravi',
      customerPhone: '+919876543210',
      serviceId: 'svc1',
      date: '2024-01-20',
      timeSlot: '10:30',
      staffId: 'staff1',
    );

    expect(result.id, 'book1');
    expect(result.customerName, 'Ravi');
    expect(result.customerPhone, '+919876543210');
    expect(result.serviceId, 'svc1');
    expect(result.staffId, 'staff1');
    expect(result.date, '2024-01-20');
    expect(result.timeSlot, '10:30');
    expect(result.status, BookingStatus.confirmed);

    final captured =
        verify(() => functions.call(FunctionsService.createBooking, captureAny())).captured;
    final params = captured.single as Map<String, dynamic>;
    expect(params['tenantId'], 'ten1');
    expect(params['customerName'], 'Ravi');
    expect(params['customerPhone'], '+919876543210');
    expect(params['serviceId'], 'svc1');
    expect(params['date'], '2024-01-20');
    expect(params['timeSlot'], '10:30');
    expect(params['staffId'], 'staff1');
  });

  test('createBooking omits staffId from params when not provided', () async {
    final functions = MockFunctionsService();
    final firestore = MockFirebaseFirestore();
    final repo = BookingRepository(functions, firestore);
    when(() => functions.call(FunctionsService.createBooking, any())).thenAnswer(
      (_) async => {
        'id': 'book2',
        'entry': {
          'customerName': 'Nina',
          'customerPhone': '+91',
          'serviceId': 'svc1',
          'date': '2024-01-21',
          'timeSlot': '11:00',
          'status': 'confirmed',
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 15, 10, 0, 0)),
          'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 15, 10, 0, 0)),
        },
      },
    );

    await repo.createBooking(
      tenantId: 'ten1',
      customerName: 'Nina',
      customerPhone: '+91',
      serviceId: 'svc1',
      date: '2024-01-21',
      timeSlot: '11:00',
    );

    final captured =
        verify(() => functions.call(FunctionsService.createBooking, captureAny())).captured;
    final params = captured.single as Map<String, dynamic>;
    expect(params.containsKey('staffId'), isFalse);
  });

  test('cancelBooking calls cancelBooking function and parses result', () async {
    final functions = MockFunctionsService();
    final firestore = MockFirebaseFirestore();
    final repo = BookingRepository(functions, firestore);
    when(() => functions.call(FunctionsService.cancelBooking, any())).thenAnswer(
      (_) async => {
        'id': 'book1',
        'entry': {
          'customerName': 'Ravi',
          'customerPhone': '+919876543210',
          'serviceId': 'svc1',
          'date': '2024-01-20',
          'timeSlot': '10:30',
          'status': 'cancelled',
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 15, 10, 0, 0)),
          'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 16, 9, 0, 0)),
        },
      },
    );

    final result = await repo.cancelBooking('ten1', 'book1');

    expect(result.id, 'book1');
    expect(result.status, BookingStatus.cancelled);

    final captured =
        verify(() => functions.call(FunctionsService.cancelBooking, captureAny())).captured;
    final params = captured.single as Map<String, dynamic>;
    expect(params['tenantId'], 'ten1');
    expect(params['bookingId'], 'book1');
  });

  test('convertToToken calls convertBookingToToken function and parses result', () async {
    final functions = MockFunctionsService();
    final firestore = MockFirebaseFirestore();
    final repo = BookingRepository(functions, firestore);
    when(() => functions.call(FunctionsService.convertBookingToToken, any())).thenAnswer(
      (_) async => {
        'id': 'book1',
        'entry': {
          'customerName': 'Ravi',
          'customerPhone': '+919876543210',
          'serviceId': 'svc1',
          'date': '2024-01-20',
          'timeSlot': '10:30',
          'status': 'completed',
          'tokenId': 'tok42',
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 15, 10, 0, 0)),
          'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 16, 9, 0, 0)),
        },
      },
    );

    final result = await repo.convertToToken('ten1', 'book1');

    expect(result.id, 'book1');
    expect(result.status, BookingStatus.completed);
    expect(result.tokenId, 'tok42');

    final captured = verify(
        () => functions.call(FunctionsService.convertBookingToToken, captureAny())).captured;
    final params = captured.single as Map<String, dynamic>;
    expect(params['tenantId'], 'ten1');
    expect(params['bookingId'], 'book1');
  });

  test('availableSlots returns slots list from function result', () async {
    final functions = MockFunctionsService();
    final firestore = MockFirebaseFirestore();
    final repo = BookingRepository(functions, firestore);
    when(() => functions.call('getAvailableSlots', any())).thenAnswer(
      (_) async => {
        'slots': ['09:00', '09:30', '10:00'],
      },
    );

    final slots = await repo.availableSlots(
      tenantId: 'ten1',
      serviceId: 'svc1',
      date: '2024-01-20',
    );

    expect(slots, ['09:00', '09:30', '10:00']);
    final captured = verify(() => functions.call('getAvailableSlots', captureAny())).captured;
    final params = captured.single as Map<String, dynamic>;
    expect(params['tenantId'], 'ten1');
    expect(params['serviceId'], 'svc1');
    expect(params['date'], '2024-01-20');
    expect(params.containsKey('staffId'), isFalse);
  });

  test('availableSlots includes staffId in params when provided', () async {
    final functions = MockFunctionsService();
    final firestore = MockFirebaseFirestore();
    final repo = BookingRepository(functions, firestore);
    when(() => functions.call('getAvailableSlots', any())).thenAnswer(
      (_) async => {'slots': <String>[]},
    );

    await repo.availableSlots(
      tenantId: 'ten1',
      serviceId: 'svc1',
      date: '2024-01-20',
      staffId: 'staff1',
    );

    final captured = verify(() => functions.call('getAvailableSlots', captureAny())).captured;
    final params = captured.single as Map<String, dynamic>;
    expect(params['staffId'], 'staff1');
  });

  test('bookingsForDate emits bookings ordered by timeSlot', () async {
    final functions = MockFunctionsService();
    final firestore = FakeFirebaseFirestore();
    final repo = BookingRepository(functions, firestore);
    final bookings = firestore
        .collection('tenants')
        .doc('ten1')
        .collection('bookings');

    await bookings.doc('b1').set({
      'customerName': 'B',
      'customerPhone': '+91',
      'serviceId': 'svc1',
      'date': '2024-01-20',
      'timeSlot': '11:00',
      'status': 'confirmed',
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });
    await bookings.doc('b2').set({
      'customerName': 'A',
      'customerPhone': '+91',
      'serviceId': 'svc1',
      'date': '2024-01-20',
      'timeSlot': '09:00',
      'status': 'confirmed',
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });
    await bookings.doc('b3').set({
      'customerName': 'C',
      'customerPhone': '+91',
      'serviceId': 'svc1',
      'date': '2024-01-21',
      'timeSlot': '09:00',
      'status': 'confirmed',
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });

    final emitted = await repo.bookingsForDate('ten1', '2024-01-20').first;

    expect(emitted.length, 2);
    expect(emitted[0].id, 'b2');
    expect(emitted[0].timeSlot, '09:00');
    expect(emitted[1].id, 'b1');
    expect(emitted[1].timeSlot, '11:00');
  });
}
