// Barber, Service, Tenant, SubscriptionPlan models

// ──────────────────────────────────────────────
// Subscription Plans
// ──────────────────────────────────────────────

enum SubscriptionPlan {
  starter(level: 0, name: 'Starter', price: 199, maxServices: 5, maxBarbers: 2,
    appointments: false, qrCode: false, reports: 'basic', customerHistory: false, customTimeSlots: false),
  pro(level: 1, name: 'Pro', price: 499, maxServices: 20, maxBarbers: 10,
    appointments: true, qrCode: true, reports: 'full', customerHistory: true, customTimeSlots: true),
  clinic(level: 2, name: 'Clinic', price: 349, maxServices: 10, maxBarbers: 5,
    appointments: true, qrCode: true, reports: 'full', customerHistory: true, customTimeSlots: true);

  const SubscriptionPlan({
    required this.level, required this.name, required this.price,
    required this.maxServices, required this.maxBarbers,
    required this.appointments, required this.qrCode,
    required this.reports, required this.customerHistory,
    required this.customTimeSlots,
  });

  final int level;
  final String name;
  final int price;
  final int maxServices;
  final int maxBarbers;
  final bool appointments;
  final bool qrCode;
  final String reports; // 'basic' | 'full'
  final bool customerHistory;
  final bool customTimeSlots;

  static SubscriptionPlan fromLevel(int level) {
    return SubscriptionPlan.values.firstWhere((p) => p.level == level, orElse: () => SubscriptionPlan.starter);
  }
}

// ──────────────────────────────────────────────
// Barber
// ──────────────────────────────────────────────

class Barber {
  final String id;
  final String name;
  final String? photoURL;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int order;
  final String? scheduleStart; // HH:MM
  final String? scheduleEnd;   // HH:MM
  final List<String> serviceIds; // IDs of services this barber can perform

  Barber({
    this.id = '', this.name = '', this.photoURL, this.isActive = true,
    this.createdAt, this.updatedAt, this.order = 0,
    this.scheduleStart, this.scheduleEnd,
    this.serviceIds = const [],
  });

  factory Barber.fromMap(Map<String, dynamic> map, String id) => Barber(
    id: id, name: map['name'] ?? '', photoURL: map['photoURL'],
    isActive: map['isActive'] ?? true, order: map['order'] ?? 0,
    scheduleStart: map['scheduleStart'], scheduleEnd: map['scheduleEnd'],
    serviceIds: List<String>.from(map['serviceIds'] ?? []),
    createdAt: map['createdAt']?.toDate(), updatedAt: map['updatedAt']?.toDate(),
  );

  Map<String, dynamic> toMap() => {
    'name': name, 'photoURL': photoURL, 'isActive': isActive,
    'order': order, 'scheduleStart': scheduleStart, 'scheduleEnd': scheduleEnd,
    'serviceIds': serviceIds,
    if (createdAt != null) 'createdAt': createdAt,
    'updatedAt': DateTime.now(),
  };
}

// ──────────────────────────────────────────────
// Service (with category + plan gating)
// ──────────────────────────────────────────────

enum ServiceCategory { hair, beard, facial, massage, spa, treatment, consultation, other }

extension ServiceCategoryExt on ServiceCategory {
  String get label {
    switch (this) {
      case ServiceCategory.hair: return 'Hair';
      case ServiceCategory.beard: return 'Beard';
      case ServiceCategory.facial: return 'Facial';
      case ServiceCategory.massage: return 'Massage';
      case ServiceCategory.spa: return 'Spa';
      case ServiceCategory.treatment: return 'Treatment';
      case ServiceCategory.consultation: return 'Consultation';
      case ServiceCategory.other: return 'Other';
    }
  }

  static ServiceCategory fromString(String s) {
    return ServiceCategory.values.firstWhere((c) => c.name == s, orElse: () => ServiceCategory.other);
  }
}

class Service {
  final String id;
  final String name;
  final int durationMin;
  final int price;
  final bool isActive;
  final String? tenantId;
  final ServiceCategory category;
  final int planMinLevel; // minimum plan level required for this service

  Service({
    this.id = '', this.name = '', this.durationMin = 0, this.price = 0,
    this.isActive = true, this.tenantId, this.category = ServiceCategory.hair,
    this.planMinLevel = 0,
  });

  factory Service.fromMap(Map<String, dynamic> map, String id) => Service(
    id: id, name: map['name'] ?? '', durationMin: map['durationMin'] ?? 0,
    price: map['price'] ?? 0, isActive: map['isActive'] ?? true,
    tenantId: map['tenantId'],
    category: ServiceCategoryExt.fromString(map['category'] ?? 'hair'),
    planMinLevel: map['planMinLevel'] ?? 0,
  );

  Map<String, dynamic> toMap() => {
    'name': name, 'durationMin': durationMin, 'price': price,
    'isActive': isActive, 'tenantId': tenantId,
    'category': category.name, 'planMinLevel': planMinLevel,
  };
}

// ──────────────────────────────────────────────
// Tenant (with subscription plan)
// ──────────────────────────────────────────────

class Tenant {
  final String id;
  final String name;
  final String ownerEmail;
  final String businessType;
  final int planLevel;
  final String status; // pending | active | suspended
  final String bookingMode; // appointment | token
  final String phone;
  final String address;
  final String? ownerName;
  final String? ownerPhone;
  final String? createdBy; // super admin uid
  final DateTime? createdAt;
  final DateTime? configuredAt;
  final String? district;
  final String? city;
  final String? openTime;
  final String? closeTime;
  final String? slug;
  // Geo fields — optional, used to sort nearby shops by distance.
  final double? latitude;
  final double? longitude;

  Tenant({
    this.id = '', this.name = '', this.ownerEmail = '', this.businessType = 'salon',
    this.planLevel = 0, this.status = 'pending', this.bookingMode = 'token',
    this.phone = '', this.address = '',
    this.ownerName, this.ownerPhone, this.createdBy,
    this.createdAt, this.configuredAt,
    this.district, this.city, this.openTime, this.closeTime,
    this.slug,
    this.latitude, this.longitude,
  });

  SubscriptionPlan get plan => SubscriptionPlan.fromLevel(planLevel);

  /// Whether this tenant has usable coordinates for distance sorting.
  bool get hasCoordinates => latitude != null && longitude != null;

  Tenant copyWith({
    String? id,
    String? name,
    String? ownerEmail,
    String? businessType,
    int? planLevel,
    String? status,
    String? bookingMode,
    String? phone,
    String? address,
    String? ownerName,
    String? ownerPhone,
    String? createdBy,
    DateTime? createdAt,
    DateTime? configuredAt,
    String? district,
    String? city,
    String? openTime,
    String? closeTime,
    String? slug,
    double? latitude,
    double? longitude,
  }) {
    return Tenant(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      businessType: businessType ?? this.businessType,
      planLevel: planLevel ?? this.planLevel,
      status: status ?? this.status,
      bookingMode: bookingMode ?? this.bookingMode,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      ownerName: ownerName ?? this.ownerName,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      configuredAt: configuredAt ?? this.configuredAt,
      district: district ?? this.district,
      city: city ?? this.city,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      slug: slug ?? this.slug,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  factory Tenant.fromMap(Map<String, dynamic> map, String id) => Tenant(
    id: id, name: map['name'] ?? '', ownerEmail: map['ownerEmail'] ?? '',
    businessType: map['businessType'] ?? 'salon', planLevel: map['planLevel'] ?? 0,
    status: map['status'] ?? 'pending', bookingMode: map['bookingMode'] ?? 'token',
    phone: map['phone'] ?? '', address: map['address'] ?? '',
    ownerName: map['ownerName'], ownerPhone: map['ownerPhone'],
    createdBy: map['createdBy'], createdAt: map['createdAt']?.toDate(),
    configuredAt: map['configuredAt']?.toDate(),
    district: map['district'], city: map['city'],
    openTime: map['openTime'], closeTime: map['closeTime'],
    slug: map['slug'],
    latitude: _toDouble(map['latitude']), longitude: _toDouble(map['longitude']),
  );

  Map<String, dynamic> toMap() => {
    'name': name, 'ownerEmail': ownerEmail, 'businessType': businessType,
    'planLevel': planLevel, 'status': status, 'bookingMode': bookingMode,
    'phone': phone, 'address': address,
    'ownerName': ownerName, 'ownerPhone': ownerPhone,
    'createdBy': createdBy, 'createdAt': createdAt,
    'configuredAt': configuredAt,
    'district': district, 'city': city,
    'openTime': openTime, 'closeTime': closeTime,
    if (slug != null) 'slug': slug,
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
  };
}

/// Coerces Firestore numeric types (int/double/num) into a nullable double.
double? _toDouble(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is num) return v.toDouble();
  return null;
}
