import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qcut_flutter/data/services/functions_service.dart';
import 'package:qcut_flutter/domain/models/token_entry.dart';

class QueueRepository {
  final FunctionsService _functions;
  final FirebaseFirestore _firestore;

  QueueRepository(this._functions, this._firestore);

  Stream<List<TokenEntry>> tokenStream(String tenantId, {String? date}) {
    final d = date ?? _today();
    return _firestore
        .collection('tenants')
        .doc(tenantId)
        .collection('tokens')
        .doc(d)
        .collection('entries')
        .orderBy('tokenNumber')
        .snapshots()
        .map((snap) => snap.docs.map((d) => TokenEntry.fromMap(d.data(), d.id)).toList());
  }

  Future<TokenEntry> issueToken({
    required String tenantId,
    required String customerName,
    required String customerPhone,
    String? staffId,
    String? serviceId,
    String? bookingId,
    String source = 'walk_in',
  }) async {
    final result = await _functions.call(FunctionsService.issueToken, {
      'tenantId': tenantId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      if (staffId != null) 'staffId': staffId,
      if (serviceId != null) 'serviceId': serviceId,
      if (bookingId != null) 'bookingId': bookingId,
      'source': source,
    });
    return TokenEntry.fromMap(result['entry'] as Map<String, dynamic>, result['id'] as String);
  }

  Future<TokenEntry> callNext(String tenantId, {String? staffId}) async {
    final result = await _functions.call(FunctionsService.callNextToken, {
      'tenantId': tenantId,
      if (staffId != null) 'staffId': staffId,
    });
    return TokenEntry.fromMap(result['entry'] as Map<String, dynamic>, result['id'] as String);
  }

  Future<TokenEntry> completeToken(String tenantId, String entryId) async {
    final result = await _functions.call(FunctionsService.completeToken, {
      'tenantId': tenantId,
      'entryId': entryId,
    });
    return TokenEntry.fromMap(result['entry'] as Map<String, dynamic>, result['id'] as String);
  }

  Future<TokenEntry> markNoShow(String tenantId, String entryId) async {
    final result = await _functions.call(FunctionsService.noShowToken, {
      'tenantId': tenantId,
      'entryId': entryId,
    });
    return TokenEntry.fromMap(result['entry'] as Map<String, dynamic>, result['id'] as String);
  }

  String _today() => DateTime.now().toIso8601String().substring(0, 10);
}
