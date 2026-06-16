class SubscriptionPlan {
  final String id;
  final String name;
  final int price;
  final int maxServices;
  final int maxStaff;
  final bool appointmentsEnabled;
  final bool qrCodeEnabled;
  final bool customTimeSlots;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.maxServices,
    required this.maxStaff,
    required this.appointmentsEnabled,
    required this.qrCodeEnabled,
    required this.customTimeSlots,
  });

  factory SubscriptionPlan.fromMap(Map<String, dynamic> map, String id) {
    return SubscriptionPlan(
      id: id,
      name: map['name'] as String? ?? '',
      price: map['price'] as int? ?? 0,
      maxServices: map['maxServices'] as int? ?? 0,
      maxStaff: map['maxStaff'] as int? ?? 0,
      appointmentsEnabled: map['appointmentsEnabled'] as bool? ?? false,
      qrCodeEnabled: map['qrCodeEnabled'] as bool? ?? false,
      customTimeSlots: map['customTimeSlots'] as bool? ?? false,
    );
  }
}
