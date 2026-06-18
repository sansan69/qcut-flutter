import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qcut_flutter/ui/provider/calendar_view_model.dart';
import 'package:qcut_flutter/data/repositories/booking_repository.dart';
import 'package:qcut_flutter/domain/models/booking.dart';

class MockBookingRepository extends Mock implements BookingRepository {}

Booking _booking() => Booking(
      id: 'b1',
      customerName: 'A',
      customerPhone: '+91',
      serviceId: 's1',
      date: '2024-01-15',
      timeSlot: '10:00',
      status: BookingStatus.confirmed,
      createdAt: DateTime(2024, 1, 15),
      updatedAt: DateTime(2024, 1, 15),
    );

void main() {
  late MockBookingRepository repo;
  late CalendarViewModel vm;

  setUp(() {
    repo = MockBookingRepository();
    vm = CalendarViewModel(repository: repo, tenantId: 't1');
  });

  tearDown(() => vm.dispose());

  test('selectDate calls bookingsForDate with ISO date string', () async {
    final date = DateTime(2024, 1, 15);
    final dateStr = date.toIso8601String().substring(0, 10);
    when(() => repo.bookingsForDate('t1', dateStr))
        .thenAnswer((_) => Stream.value(<Booking>[]));

    vm.selectDate(date);
    await Future.delayed(Duration.zero);

    verify(() => repo.bookingsForDate('t1', dateStr)).called(1);
  });

  test('selectDate exposes emitted bookings', () async {
    final date = DateTime(2024, 1, 15);
    final dateStr = date.toIso8601String().substring(0, 10);
    final bookings = [_booking()];
    when(() => repo.bookingsForDate('t1', dateStr))
        .thenAnswer((_) => Stream.value(bookings));

    vm.selectDate(date);
    await Future.delayed(Duration.zero);

    expect(vm.bookings, bookings);
    expect(vm.selectedDate, date);
  });

  test('convertToToken invokes repository with tenant and booking id', () async {
    when(() => repo.convertToToken('t1', 'b1'))
        .thenAnswer((_) async => _booking());

    await vm.convertToToken('b1');

    verify(() => repo.convertToToken('t1', 'b1')).called(1);
  });

  test('convertToToken toggles loading flag', () async {
    when(() => repo.convertToToken('t1', 'b1'))
        .thenAnswer((_) async => _booking());

    expect(vm.loading, isFalse);
    final future = vm.convertToToken('b1');
    expect(vm.loading, isTrue);
    await future;
    expect(vm.loading, isFalse);
  });
}
