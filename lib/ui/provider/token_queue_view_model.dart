import 'package:flutter/foundation.dart';
import 'package:qcut_flutter/data/repositories/queue_repository.dart';
import 'package:qcut_flutter/domain/models/token_entry.dart';

class TokenQueueViewModel extends ChangeNotifier {
  final QueueRepository _repository;
  final String tenantId;

  TokenQueueViewModel({required QueueRepository repository, required this.tenantId})
      : _repository = repository;

  bool _loading = false;
  String? _error;

  bool get loading => _loading;
  String? get error => _error;

  Stream<List<TokenEntry>> get tokenStream => _repository.tokenStream(tenantId);

  Future<void> callNext() async {
    _setLoading(true);
    try {
      await _repository.callNext(tenantId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> complete(String entryId) async {
    _setLoading(true);
    try {
      await _repository.completeToken(tenantId, entryId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> noShow(String entryId) async {
    _setLoading(true);
    try {
      await _repository.markNoShow(tenantId, entryId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
