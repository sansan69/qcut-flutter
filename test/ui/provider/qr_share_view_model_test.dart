import 'package:flutter_test/flutter_test.dart';
import 'package:qcut_flutter/ui/provider/qr_share_view_model.dart';

void main() {
  late QrShareViewModel vm;

  setUp(() {
    vm = QrShareViewModel(tenantSlug: 'acme-salon');
  });

  tearDown(() => vm.dispose());

  test('bookingUrl returns https://qcut.co.in/s/{slug}', () {
    expect(vm.bookingUrl, 'https://qcut.co.in/s/acme-salon');
  });

  test('bookingUrl reflects tenant slug', () {
    final other = QrShareViewModel(tenantSlug: 'raj-barbers');
    expect(other.bookingUrl, 'https://qcut.co.in/s/raj-barbers');
    other.dispose();
  });
}
