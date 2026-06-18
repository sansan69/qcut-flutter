import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qcut_flutter/data/repositories/tenant_repository.dart';
import 'package:qcut_flutter/domain/models/tenant.dart';
import 'package:qcut_flutter/ui/platform_admin/tenant_list_view_model.dart';

class MockTenantRepository extends Mock implements TenantRepository {}

void main() {
  late TenantListViewModel viewModel;
  late MockTenantRepository repository;

  setUp(() {
    repository = MockTenantRepository();
    viewModel = TenantListViewModel(repository: repository);
  });

  tearDown(() => viewModel.dispose());

  test('loadTenants fetches and exposes tenants', () async {
    final tenants = [
      const Tenant(
        id: 't1',
        slug: 'acme-salon',
        name: 'Acme Salon',
        type: 'salon',
        ownerUid: 'u1',
        planId: 'starter',
        status: 'active',
      ),
    ];
    when(() => repository.listTenants()).thenAnswer((_) async => tenants);

    await viewModel.loadTenants();

    expect(viewModel.loading, isFalse);
    expect(viewModel.tenants, equals(tenants));
    verify(() => repository.listTenants()).called(1);
  });

  test('suspend updates status and reloads list', () async {
    when(() => repository.listTenants()).thenAnswer((_) async => []);
    when(() => repository.updateTenantStatus(any(), any()))
        .thenAnswer((_) async {});

    await viewModel.suspend('t1');

    verify(() => repository.updateTenantStatus('t1', 'suspended')).called(1);
    verify(() => repository.listTenants()).called(1);
  });

  test('activate updates status and reloads list', () async {
    when(() => repository.listTenants()).thenAnswer((_) async => []);
    when(() => repository.updateTenantStatus(any(), any()))
        .thenAnswer((_) async {});

    await viewModel.activate('t1');

    verify(() => repository.updateTenantStatus('t1', 'active')).called(1);
  });
}
