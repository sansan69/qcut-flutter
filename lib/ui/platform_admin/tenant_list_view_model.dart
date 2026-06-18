import 'package:flutter/foundation.dart';
import 'package:qcut_flutter/data/repositories/tenant_repository.dart';
import 'package:qcut_flutter/domain/models/tenant.dart';

class TenantListViewModel extends ChangeNotifier {
  final TenantRepository _repository;

  TenantListViewModel({required TenantRepository repository})
      : _repository = repository;

  List<Tenant> _tenants = [];
  bool _loading = false;

  List<Tenant> get tenants => _tenants;
  bool get loading => _loading;

  Future<void> loadTenants() async {
    _loading = true;
    notifyListeners();
    _tenants = await _repository.listTenants();
    _loading = false;
    notifyListeners();
  }

  Future<void> suspend(String tenantId) async {
    await _repository.updateTenantStatus(tenantId, 'suspended');
    await loadTenants();
  }

  Future<void> activate(String tenantId) async {
    await _repository.updateTenantStatus(tenantId, 'active');
    await loadTenants();
  }
}
