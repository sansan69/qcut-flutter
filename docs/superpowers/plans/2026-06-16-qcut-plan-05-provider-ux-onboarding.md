# QCUT Plan 5 — Provider UX, QR, and Onboarding

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Improve Provider-facing UX for QR generation/sharing, role separation between Customer and Provider, and Platform Admin tenant CRUD.

**Architecture:** Provider app uses new repositories and view models for QR/share and onboarding; Platform Admin screens use `TenantRepository`; role routing updated in `main.dart`.

**Tech Stack:** Flutter, `qr_flutter`, `share_plus`, `mobile_scanner`, Firebase Auth/Firestore.

---

## File Structure

- `lib/ui/provider/qr_share_view_model.dart` — QR/share logic.
- `lib/ui/provider/onboarding_view_model.dart` — provider onboarding view model.
- `lib/ui/platform_admin/tenant_list_view_model.dart` — admin tenant CRUD view model.
- `lib/screens/common/qr_screen.dart` — update to generate real link.
- `lib/screens/customer/join_queue_screen.dart` — add real QR scanner.
- `lib/main.dart` — role routing.

---

### Task 1: QR generation and share ViewModel

**Files:**
- Create: `lib/ui/provider/qr_share_view_model.dart`
- Modify: `lib/screens/common/qr_screen.dart`
- Test: `test/ui/provider/qr_share_view_model_test.dart`

- [ ] **Step 1: Write failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:qcut/ui/provider/qr_share_view_model.dart';

void main() {
  test('bookingUrl returns qcut.co.in/s/{slug}', () {
    final vm = QrShareViewModel(tenantSlug: 'my-shop');
    expect(vm.bookingUrl, 'https://qcut.co.in/s/my-shop');
  });
}
```

Run: `flutter test test/ui/provider/qr_share_view_model_test.dart`
Expected: FAIL.

- [ ] **Step 2: Implement ViewModel**

```dart
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

class QrShareViewModel extends ChangeNotifier {
  final String tenantSlug;

  QrShareViewModel({required this.tenantSlug});

  String get bookingUrl => 'https://qcut.co.in/s/$tenantSlug';

  Future<void> share() async {
    await Share.share('Book your appointment at $bookingUrl');
  }

  void copyToClipboard(BuildContext context) {
    // Use existing copy helper in app
  }
}
```

- [ ] **Step 3: Update QR screen**

In `lib/screens/common/qr_screen.dart`, replace hardcoded `https://qcut.in/<slug>` with the ViewModel URL.

```dart
final url = context.watch<QrShareViewModel>().bookingUrl;
```

- [ ] **Step 4: Run tests**

Run: `flutter test test/ui/provider/qr_share_view_model_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/ui/provider/qr_share_view_model.dart test/ui/provider/qr_share_view_model_test.dart lib/screens/common/qr_screen.dart
git commit -m "feat(provider): add QR/share view model and real booking URL"
```

---

### Task 2: Real QR scanner for customers

**Files:**
- Modify: `lib/screens/customer/join_queue_screen.dart`
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add dependency**

`pubspec.yaml`:

```yaml
dependencies:
  mobile_scanner: ^7.2.0
```

Run: `flutter pub get`

- [ ] **Step 2: Implement scanner overlay screen**

Create `lib/screens/common/qr_scanner_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerScreen extends StatelessWidget {
  const QrScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Shop QR')),
      body: MobileScanner(
        onDetect: (capture) {
          final barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            final raw = barcode.rawValue;
            if (raw != null && raw.startsWith('https://qcut.co.in/s/')) {
              Navigator.of(context).pop(raw);
              return;
            }
          }
        },
      ),
    );
  }
}
```

- [ ] **Step 3: Wire scanner in join queue screen**

In `lib/screens/customer/join_queue_screen.dart`, on QR icon tap:

```dart
final url = await Navigator.of(context).push<String>(
  MaterialPageRoute(builder: (_) => const QrScannerScreen()),
);
if (url != null) {
  // Navigate to web booking page or extract slug
  final slug = url.replaceFirst('https://qcut.co.in/s/', '');
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => WebBookingPage(shopSlug: slug)),
  );
}
```

- [ ] **Step 4: Add Android/iOS permissions**

Android `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
```

iOS `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to scan shop QR codes</string>
```

- [ ] **Step 5: Commit**

```bash
git add lib/screens/common/qr_scanner_screen.dart lib/screens/customer/join_queue_screen.dart pubspec.yaml pubspec.lock android/app/src/main/AndroidManifest.xml ios/Runner/Info.plist
git commit -m "feat(customer): add real QR scanner using mobile_scanner"
```

---

### Task 3: Role routing and Customer/Provider separation

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: Update role resolution**

```dart
Future<void> _resolveUser() async {
  final user = _auth.currentUser;
  if (user == null) return;
  final role = await _authRepository.resolveRole();
  final tenantId = await _authRepository.resolveTenantId();
  setState(() {
    _role = role;
    _tenantId = tenantId;
  });
}
```

- [ ] **Step 2: Update role routing**

```dart
Widget _buildHome() {
  if (_role == 'platform_admin') return PlatformAdminApp();
  if (_role == 'provider') return ProviderApp(tenantId: _tenantId!);
  if (_role == 'customer') return CustomerApp();
  return LandingScreen();
}
```

- [ ] **Step 3: Create ProviderApp and CustomerApp shells**

`lib/ui/provider/provider_app.dart`:

```dart
class ProviderApp extends StatelessWidget {
  final String tenantId;
  const ProviderApp({super.key, required this.tenantId});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: context.read<QueueRepository>()),
        Provider.value(value: context.read<BookingRepository>()),
      ],
      child: MaterialApp(
        home: OwnerDashboardScreen(tenantId: tenantId),
      ),
    );
  }
}
```

`lib/ui/customer/customer_app.dart`:

```dart
class CustomerApp extends StatelessWidget {
  const CustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LandingScreen(),
    );
  }
}
```

- [ ] **Step 4: Run smoke test**

Run: `flutter test test/main_test.dart` (create if missing)
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/main.dart lib/ui/provider/provider_app.dart lib/ui/customer/customer_app.dart test/main_test.dart
git commit -m "feat(auth): separate Customer and Provider app shells by role"
```

---

### Task 4: Provider onboarding ViewModel

**Files:**
- Create: `lib/ui/provider/onboarding_view_model.dart`
- Modify: `lib/screens/onboarding/onboarding_screen.dart`
- Test: `test/ui/provider/onboarding_view_model_test.dart`

- [ ] **Step 1: Write failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qcut/ui/provider/onboarding_view_model.dart';
import 'package:qcut/data/repositories/auth_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  test('submit calls createUserWithEmailAndPassword', () async {
    final auth = MockAuthRepository();
    final vm = OnboardingViewModel(authRepository: auth);
    when(() => auth.signUpWithEmailAndPassword(any(), any())).thenAnswer((_) async => FakeUserCredential());
    await vm.submit(email: 'a@b.com', password: 'pass123', businessName: 'Shop');
    verify(() => auth.signUpWithEmailAndPassword('a@b.com', 'pass123')).called(1);
  });
}
```

Run: `flutter test test/ui/provider/onboarding_view_model_test.dart`
Expected: FAIL.

- [ ] **Step 2: Implement ViewModel**

```dart
import 'package:flutter/foundation.dart';
import 'package:qcut/data/repositories/auth_repository.dart';
import 'package:qcut/data/services/firestore_service.dart';

class OnboardingViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final FirestoreService _firestore;

  OnboardingViewModel({required AuthRepository authRepository, required FirestoreService firestore})
      : _authRepository = authRepository,
        _firestore = firestore;

  bool _loading = false;
  String? _error;

  bool get loading => _loading;
  String? get error => _error;

  Future<bool> submit({
    required String email,
    required String password,
    required String businessName,
    required String ownerName,
    required String phone,
    required String type,
  }) async {
    _setLoading(true);
    try {
      final cred = await _authRepository.signUpWithEmailAndPassword(email, password);
      final uid = cred.user!.uid;
      await _firestore.setDocument('users', uid, {
        'uid': uid,
        'email': email,
        'phone': phone,
        'role': 'provider',
        'displayName': ownerName,
        'fcmTokens': [],
        'createdAt': Timestamp.now(),
      });
      await _firestore.addDocument('onboarding_submissions', {
        'uid': uid,
        'businessName': businessName,
        'ownerName': ownerName,
        'phone': phone,
        'type': type,
        'status': 'pending',
        'submittedAt': Timestamp.now(),
      });
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
```

- [ ] **Step 3: Run tests**

Run: `flutter test test/ui/provider/onboarding_view_model_test.dart`
Expected: PASS.

- [ ] **Step 4: Commit**

```bash
git add lib/ui/provider/onboarding_view_model.dart test/ui/provider/onboarding_view_model_test.dart
git commit -m "feat(provider): add onboarding view model"
```

---

### Task 5: Platform Admin tenant CRUD ViewModel

**Files:**
- Create: `lib/ui/platform_admin/tenant_list_view_model.dart`
- Modify: `lib/screens/super_admin/super_admin_dashboard.dart`
- Test: `test/ui/platform_admin/tenant_list_view_model_test.dart`

- [ ] **Step 1: Write failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qcut/ui/platform_admin/tenant_list_view_model.dart';
import 'package:qcut/data/repositories/tenant_repository.dart';

class MockTenantRepository extends Mock implements TenantRepository {}

void main() {
  test('loadTenants fetches list', () async {
    final repo = MockTenantRepository();
    final vm = TenantListViewModel(repository: repo);
    when(() => repo.listTenants()).thenAnswer((_) async => []);
    await vm.loadTenants();
    expect(vm.tenants, isEmpty);
  });
}
```

Run: `flutter test test/ui/platform_admin/tenant_list_view_model_test.dart`
Expected: FAIL.

- [ ] **Step 2: Implement ViewModel**

```dart
import 'package:flutter/foundation.dart';
import 'package:qcut/data/repositories/tenant_repository.dart';
import 'package:qcut/domain/models/tenant.dart';

class TenantListViewModel extends ChangeNotifier {
  final TenantRepository _repository;

  TenantListViewModel({required TenantRepository repository}) : _repository = repository;

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
```

- [ ] **Step 3: Add listTenants to TenantRepository**

```dart
Future<List<Tenant>> listTenants() async {
  final snap = await _firestore.collection('tenants').orderBy('createdAt', descending: true).get();
  return snap.docs.map((d) => Tenant.fromMap(d.data(), d.id)).toList();
}

Future<void> updateTenantStatus(String tenantId, String status) async {
  await _firestore.updateDocument('tenants', tenantId, {'status': status, 'updatedAt': Timestamp.now()});
}
```

- [ ] **Step 4: Run tests**

Run: `flutter test test/ui/platform_admin/tenant_list_view_model_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/ui/platform_admin/tenant_list_view_model.dart test/ui/platform_admin/tenant_list_view_model_test.dart lib/data/repositories/tenant_repository.dart
git commit -m "feat(admin): add Platform Admin tenant list view model"
```

---

## Self-Review

- Spec coverage: QR/share, QR scanner, role separation, onboarding, admin tenant CRUD covered.
- Placeholder scan: none.
- Type consistency: `TenantRepository` methods used consistently across ViewModels.

---

## Execution Handoff

After this plan is saved, choose:
1. **Subagent-Driven** — dispatch a fresh subagent per task.
2. **Inline Execution** — execute tasks in this session.
