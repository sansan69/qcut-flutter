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
        .set(service.toMap());
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

  // ──────────────────────────────────────────────
  // Super Admin
  // ──────────────────────────────────────────────

  /// All tenants for super admin dashboard
  Stream<List<Tenant>> allTenants() {
    return _db.collection('tenants').orderBy('createdAt', descending: true).snapshots().map(
      (snap) => snap.docs.map((d) => Tenant.fromMap(d.data(), d.id)).toList(),
    );
  }

  /// Pending onboarding submissions
  Stream<List<Map<String, dynamic>>> pendingOnboarding() {
    return _db.collection('onboarding_submissions')
        .where('status', isEqualTo: 'pending')
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  /// Create a new tenant (super admin action)
  Future<String> createTenant(Map<String, dynamic> data) async {
    final doc = await _db.collection('tenants').add({
      ...data,
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  /// Update tenant plan or status
  Future<void> updateTenantPlan(String tenantId, int planLevel) {
    return _db.collection('tenants').doc(tenantId).update({
      'planLevel': planLevel,
      'configuredAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateTenantStatus(String tenantId, String status) {
    return _db.collection('tenants').doc(tenantId).update({'status': status});
  }

  /// Approve onboarding → create tenant automatically
  Future<void> approveOnboarding(String submissionId, Map<String, dynamic> data, int planLevel) async {
    // Create tenant
    await _db.collection('tenants').add({
      'name': data['businessName'] ?? '',
      'ownerEmail': data['businessEmail'] ?? data['ownerEmail'] ?? '',
      'ownerName': data['ownerName'] ?? '',
      'ownerPhone': data['ownerPhone'] ?? '',
      'businessType': data['businessType'] ?? 'salon',
      'phone': data['businessPhone'] ?? '',
      'address': data['street'] ?? '',
      'district': data['district'] ?? '',
      'city': data['city'] ?? '',
      'bookingMode': data['bookingMode'] ?? 'token',
      'planLevel': planLevel,
      'status': 'active',
      'openTime': data['openingTime'] ?? '09:00',
      'closeTime': data['closingTime'] ?? '21:00',
      'createdAt': FieldValue.serverTimestamp(),
      'configuredAt': FieldValue.serverTimestamp(),
    });
    // Mark submission as approved
    await _db.collection('onboarding_submissions').doc(submissionId).update({
      'status': 'approved',
      'planLevel': planLevel,
      'approvedAt': FieldValue.serverTimestamp(),
    });
  }
}
