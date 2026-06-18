import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qcut_flutter/domain/models/tenant.dart';

class TenantRepository {
  final FirebaseFirestore _firestore;

  TenantRepository(this._firestore);

  Future<Tenant?> fetchBySlug(String slug) async {
    final snap = await _firestore
        .collection('tenants')
        .where('slug', isEqualTo: slug)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return Tenant.fromMap(snap.docs.first.data(), snap.docs.first.id);
  }

  Future<List<Tenant>> listTenants() async {
    final snap = await _firestore
        .collection('tenants')
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => Tenant.fromMap(d.data(), d.id)).toList();
  }

  Future<void> updateTenantStatus(String tenantId, String status) async {
    await _firestore.collection('tenants').doc(tenantId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
