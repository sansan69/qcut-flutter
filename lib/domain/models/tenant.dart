class Tenant {
  final String id;
  final String slug;
  final String name;
  final String type;
  final String ownerUid;
  final String planId;
  final String status;

  const Tenant({
    required this.id,
    required this.slug,
    required this.name,
    required this.type,
    required this.ownerUid,
    required this.planId,
    required this.status,
  });

  factory Tenant.fromMap(Map<String, dynamic> map, String id) {
    return Tenant(
      id: id,
      slug: map['slug'] as String? ?? '',
      name: map['name'] as String? ?? '',
      type: map['type'] as String? ?? 'barbershop',
      ownerUid: map['ownerUid'] as String? ?? '',
      planId: map['planId'] as String? ?? 'starter',
      status: map['status'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() => {
        'slug': slug,
        'name': name,
        'type': type,
        'ownerUid': ownerUid,
        'planId': planId,
        'status': status,
      };
}
