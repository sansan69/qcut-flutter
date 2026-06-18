import 'package:flutter/foundation.dart';
import 'package:qcut_flutter/data/repositories/booking_repository.dart';
import 'package:qcut_flutter/domain/models/booking.dart';

class CalendarViewModel extends ChangeNotifier {
  final BookingRepository _repository;
  final String tenantId;

  CalendarViewModel({
    required BookingRepository repository,
    required this.tenantId,
  }) : _repository = repository;

  DateTime _selectedDate = DateTime.now();
  List<Booking> _bookings = [];
  bool _loading = false;

  DateTime get selectedDate => _selectedDate;
  List<Booking> get bookings => _bookings;
  bool get loading => _loading;

  Stream<List<Booking>>? _subscription;

  void selectDate(DateTime date) {
    _selectedDate = date;
    _subscription?.cancel();
    _subscription = _repository.bookingsForDate(tenantId, _format(date)).listen((list) {
      _bookings = list;
      notifyListeners();
    });
    notifyListeners();
  }

  Future<void> convertToToken(String bookingId) async {
    _loading = true;
    notifyListeners();
    await _repository.convertToToken(tenantId, bookingId);
    _loading = false;
    notifyListeners();
  }

  String _format(DateTime d) => d.toIso8601String().substring(0, 10);

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
