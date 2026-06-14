import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/token_entry.dart';
import '../models/booking.dart';
import '../models/shop_models.dart';

/// Central Firestore data layer — all CRUD for Q-CUT
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Tokens ──
  Stream<List<TokenEntry>> tokenQueue(String tenantId, {String? date}) {
    final d = date ?? DateTime.now().toIso8601String().substring(0, 10);
    return _db
        .collection('tenants').doc(tenantId)
        .collection('tokens').doc(d)
        .collection('entries')
        .orderBy('tokenNumber', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((d) => TokenEntry.fromMap(d.data(), d.id)).toList());
  }

  Future<void> updateTokenStatus(String tenantId, String date, String tokenId, String status) {
    return _db
        .collection('tenants').doc(tenantId)
        .collection('tokens').doc(date)
        .collection('entries').doc(tokenId)
        .update({'status': status, 'updatedAt': FieldValue.serverTimestamp()});
  }

  Future<void> addToken(String tenantId, TokenEntry token) {
    final date = token.date.isEmpty ? DateTime.now().toIso8601String().substring(0, 10) : token.date;
    return _db
        .collection('tenants').doc(tenantId)
        .collection('tokens').doc(date)
        .collection('entries').doc(token.id)
        .set(token.toMap());
  }

  // ── Bookings ──
  Stream<List<Booking>> bookings(String tenantId) {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return _db
        .collection('tenants').doc(tenantId)
        .collection('bookings')
        .where('date', isGreaterThanOrEqualTo: today)
        .orderBy('date')
        .orderBy('timeSlot')
        .snapshots()
        .map((snap) => snap.docs.map((d) => Booking.fromMap(d.data(), d.id)).toList());
  }

  Future<void> updateBookingStatus(String tenantId, String bookingId, String status) {
    return _db
        .collection('tenants').doc(tenantId)
        .collection('bookings').doc(bookingId)
        .update({'status': status, 'updatedAt': FieldValue.serverTimestamp()});
  }

  Future<void> addBooking(String tenantId, Booking booking) {
    return _db
        .collection('tenants').doc(tenantId)
        .collection('bookings').doc(booking.id)
        .set(booking.toMap());
  }

  // ── Barbers ──
  Stream<List<Barber>> barbers(String tenantId) {
    return _db
        .collection('tenants').doc(tenantId)
        .collection('barbers')
        .orderBy('order')
        .snapshots()
        .map((snap) => snap.docs.map((d) => Barber.fromMap(d.data(), d.id)).toList());
  }

  Future<void> addBarber(String tenantId, Barber barber) {
    return _db
        .collection('tenants').doc(tenantId)
        .collection('barbers').doc(barber.id)
        .set(barber.toMap());
  }

  Future<void> updateBarber(String tenantId, Barber barber) {
    return _db
        .collection('tenants').doc(tenantId)
        .collection('barbers').doc(barber.id)
        .update(barber.toMap());
  }

  Future<void> deleteBarber(String tenantId, String barberId) {
    return _db
        .collection('tenants').doc(tenantId)
        .collection('barbers').doc(barberId)
        .delete();
  }

  // ── Services ──
  Stream<List<Service>> services(String tenantId) {
    return _db
        .collection('tenants').doc(tenantId)
        .collection('services')
        .snapshots()
        .map((snap) => snap.docs.map((d) => Service.fromMap(d.data(), d.id)).toList());
  }

  Future<void> addService(String tenantId, Service service) {
    return _db
        .collection('tenants').doc(tenantId)
        .collection('services').doc(service.id)
        .set({'name': service.name, 'durationMin': service.durationMin, 'price': service.price, 'isActive': service.isActive});
  }

  Future<void> deleteService(String tenantId, String serviceId) {
    return _db
        .collection('tenants').doc(tenantId)
        .collection('services').doc(serviceId)
        .delete();
  }

  // ── Tenant ──
  Future<Tenant?> getTenant(String tenantId) async {
    final doc = await _db.collection('tenants').doc(tenantId).get();
    if (!doc.exists) return null;
    return Tenant.fromMap(doc.data()!, doc.id);
  }

  Stream<Tenant?> tenantStream(String tenantId) {
    return _db.collection('tenants').doc(tenantId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Tenant.fromMap(doc.data()!, doc.id);
    });
  }

  Future<void> saveTenantSettings(String tenantId, Map<String, dynamic> settings) {
    return _db
        .collection('tenants').doc(tenantId)
        .collection('settings').doc('shop')
        .set(settings, SetOptions(merge: true));
  }

  // ── Onboarding ──
  Future<void> submitOnboarding(Map<String, dynamic> data) {
    return _db.collection('onboarding_submissions').add({
      ...data,
      'submittedAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
  }

  // ── Super Admin: List Tenants ──
  Stream<List<Tenant>> allTenants() {
    return _db.collection('tenants').snapshots().map(
      (snap) => snap.docs.map((d) => Tenant.fromMap(d.data(), d.id)).toList(),
    );
  }

  Future<void> updateTenantStatus(String tenantId, String status) {
    return _db.collection('tenants').doc(tenantId).update({'status': status});
  }
}
