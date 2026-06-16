import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db;

  FirestoreService(this._db);

  Future<Map<String, dynamic>?> getDocument(String collection, String id) async {
    final snap = await _db.collection(collection).doc(id).get();
    return snap.exists ? snap.data() : null;
  }

  Stream<Map<String, dynamic>?> documentStream(String collection, String id) {
    return _db.collection(collection).doc(id).snapshots().map((s) => s.data());
  }

  Future<String> addDocument(String collection, Map<String, dynamic> data) async {
    final ref = await _db.collection(collection).add(data);
    return ref.id;
  }

  Future<void> setDocument(String collection, String id, Map<String, dynamic> data, {bool merge = false}) async {
    await _db.collection(collection).doc(id).set(data, SetOptions(merge: merge));
  }

  Future<void> updateDocument(String collection, String id, Map<String, dynamic> data) async {
    await _db.collection(collection).doc(id).update(data);
  }

  Future<void> deleteDocument(String collection, String id) async {
    await _db.collection(collection).doc(id).delete();
  }

  Stream<List<Map<String, dynamic>>> collectionStream(
    String collection, {
    String? tenantId,
    String? orderBy,
    bool descending = false,
  }) {
    Query query = _db.collection(collection);
    if (tenantId != null) query = query.where('tenantId', isEqualTo: tenantId);
    if (orderBy != null) query = query.orderBy(orderBy, descending: descending);
    return query.snapshots().map((s) => s.docs.map((d) => d.data() as Map<String, dynamic>).toList());
  }
}
