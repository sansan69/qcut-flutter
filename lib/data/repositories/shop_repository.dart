import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qcut_flutter/data/services/location_service.dart';
import 'package:qcut_flutter/models/shop_models.dart';

/// Lightweight, customer-facing shop descriptor for browse lists.
class ShopSummary {
  final String id;
  final String name;
  final String type; // businessType
  final String address;
  final String bookingMode; // token | appointment
  final String bookingUrl;
  final double? latitude;
  final double? longitude;
  final String? district;
  final String? city;

  const ShopSummary({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.bookingMode,
    required this.bookingUrl,
    this.latitude,
    this.longitude,
    this.district,
    this.city,
  });

  bool get hasCoordinates => latitude != null && longitude != null;

  /// Distance in metres from [origin], or null if uncomputable.
  double? distanceFrom(LatLng? origin) {
    if (origin == null || !hasCoordinates) return null;
    return LocationService.distanceMeters(
      fromLat: origin.latitude,
      fromLng: origin.longitude,
      toLat: latitude,
      toLng: longitude,
    );
  }

  factory ShopSummary.fromTenant(Tenant t) {
    final slug = t.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '-').replaceAll(RegExp(r'-+'), '-').replaceAll(RegExp(r'^-|-$'), '');
    return ShopSummary(
      id: t.id,
      name: t.name,
      type: t.businessType,
      address: t.address,
      bookingMode: t.bookingMode,
      bookingUrl: slug.isNotEmpty ? 'https://qcut.co.in/s/$slug' : 'https://qcut.co.in',
      latitude: t.latitude,
      longitude: t.longitude,
      district: t.district,
      city: t.city,
    );
  }
}

/// Full shop detail needed to open a JoinQueue / Booking screen.
class ShopDetail {
  final ShopSummary summary;
  final List<Barber> barbers;
  final List<Service> services;
  final int nextToken;

  const ShopDetail({
    required this.summary,
    required this.barbers,
    required this.services,
    required this.nextToken,
  });
}

/// Customer-side read access to tenants + their subcollections.
class ShopRepository {
  FirebaseFirestore? _firestoreInstance;

  ShopRepository([FirebaseFirestore? firestore]) : _firestoreInstance = firestore;

  FirebaseFirestore get _firestore => _firestoreInstance ??= FirebaseFirestore.instance;

  /// Lists active tenants as shop summaries. When [near] is provided,
  /// shops with coordinates are sorted by ascending distance, then shops
  /// without coordinates are appended unranked.
  Future<List<ShopSummary>> listActiveShops({LatLng? near}) async {
    final snap = await _firestore
        .collection('tenants')
        .where('status', isEqualTo: 'active')
        .get();

    var shops = snap.docs.map((d) => ShopSummary.fromTenant(Tenant.fromMap(d.data(), d.id))).toList();

    if (near != null) {
      shops.sort((a, b) {
        final da = a.distanceFrom(near);
        final db = b.distanceFrom(near);
        if (da == null && db == null) return a.name.compareTo(b.name);
        if (da == null) return 1; // ranked shops first
        if (db == null) return -1;
        return da.compareTo(db);
      });
    }
    return shops;
  }

  /// Pulls everything needed to open a shop's token/booking screen.
  Future<ShopDetail> fetchShopDetail(String tenantId) async {
    final tenantDoc = await _firestore.collection('tenants').doc(tenantId).get();
    final tenant = Tenant.fromMap(tenantDoc.data() ?? {}, tenantDoc.id);
    final summary = ShopSummary.fromTenant(tenant);

    // barbers + services subcollections
    final barbersSnap = await _firestore.collection('tenants').doc(tenantId).collection('barbers').get();
    final servicesSnap = await _firestore.collection('tenants').doc(tenantId).collection('services').get();

    final barbers = barbersSnap.docs.map((d) => Barber.fromMap(d.data(), d.id)).toList();
    final services = servicesSnap.docs.map((d) => Service.fromMap(d.data(), d.id)).toList();

    // Today's token count → next token number
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final tokensSnap = await _firestore
        .collection('tenants').doc(tenantId)
        .collection('tokens').doc(today)
        .collection('entries').get();
    final nextToken = tokensSnap.docs.length + 1;

    return ShopDetail(summary: summary, barbers: barbers, services: services, nextToken: nextToken);
  }
}
