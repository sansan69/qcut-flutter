/// Barber, Service, Tenant models — ported from QCUT Kotlin
class Barber {
  final String id;
  final String name;
  final String? photoURL;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int order;

  Barber({this.id = '', this.name = '', this.photoURL, this.isActive = true, this.createdAt, this.updatedAt, this.order = 0});

  factory Barber.fromMap(Map<String, dynamic> map, String id) => Barber(
    id: id, name: map['name'] ?? '', photoURL: map['photoURL'],
    isActive: map['isActive'] ?? true, order: map['order'] ?? 0,
    createdAt: map['createdAt']?.toDate(), updatedAt: map['updatedAt']?.toDate(),
  );

  Map<String, dynamic> toMap() => {
    'name': name, 'photoURL': photoURL, 'isActive': isActive,
    'order': order, 'createdAt': createdAt, 'updatedAt': DateTime.now(),
  };
}

class Service {
  final String id;
  final String name;
  final int durationMin;
  final int price;
  final bool isActive;
  final String? tenantId;

  Service({this.id = '', this.name = '', this.durationMin = 0, this.price = 0, this.isActive = true, this.tenantId});

  factory Service.fromMap(Map<String, dynamic> map, String id) => Service(
    id: id, name: map['name'] ?? '', durationMin: map['durationMin'] ?? 0,
    price: map['price'] ?? 0, isActive: map['isActive'] ?? true, tenantId: map['tenantId'],
  );
}

class Tenant {
  final String id;
  final String name;
  final String ownerEmail;
  final String businessType;
  final int planLevel;
  final String status;
  final String bookingMode; // appointment, token
  final String phone;
  final String address;

  Tenant({this.id = '', this.name = '', this.ownerEmail = '', this.businessType = 'salon',
    this.planLevel = 1, this.status = 'active', this.bookingMode = 'token',
    this.phone = '', this.address = ''});

  factory Tenant.fromMap(Map<String, dynamic> map, String id) => Tenant(
    id: id, name: map['name'] ?? '', ownerEmail: map['ownerEmail'] ?? '',
    businessType: map['businessType'] ?? 'salon', planLevel: map['planLevel'] ?? 1,
    status: map['status'] ?? 'active', bookingMode: map['bookingMode'] ?? 'token',
    phone: map['phone'] ?? '', address: map['address'] ?? '',
  );
}
