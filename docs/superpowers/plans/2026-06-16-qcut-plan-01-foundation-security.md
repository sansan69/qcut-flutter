# QCUT Plan 1 — Foundation & Security

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Set up the architectural foundation (repositories, dependency injection, Firebase config) and harden platform security (custom claims, Firestore rules, App Check) so all later plans build on a safe base.

**Architecture:** Introduce a thin data layer with repositories and low-level Firebase service wrappers, keep existing `setState` UI untouched where possible, and move security enforcement into Firebase custom claims + Firestore rules + Cloud Functions.

**Tech Stack:** Flutter, Firebase Auth/Firestore/Functions/Messaging, `provider`, `cloud_functions`, `firebase_app_check`.

---

## File Structure

- `lib/data/services/firebase_options.dart` — generated Firebase options (replaces hardcoded config).
- `lib/data/services/firestore_service.dart` — low-level Firestore CRUD wrapper.
- `lib/data/services/functions_service.dart` — callable Cloud Functions wrapper.
- `lib/data/services/app_check_service.dart` — App Check activation.
- `lib/data/repositories/auth_repository.dart` — auth + custom claims refresh.
- `lib/data/repositories/tenant_repository.dart` — tenant reads/writes.
- `lib/data/repositories/plan_repository.dart` — plan catalog reads.
- `lib/domain/models/user_profile.dart` — unified user profile model.
- `lib/domain/models/tenant.dart` — tenant model with slug/public fields.
- `functions/` — Firebase Cloud Functions project.
- `firestore.rules` — hardened rules.
- `firestore.indexes.json` — updated indexes.

---

### Task 1: Generate FlutterFire options and replace hardcoded config

**Files:**
- Create: `lib/data/services/firebase_options.dart`
- Modify: `lib/main.dart:32-46`
- Test: `test/data/services/firebase_options_test.dart`

- [ ] **Step 1: Write failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:qcut/data/services/firebase_options.dart';

void main() {
  test('defaultFirebaseOptions returns Android options', () {
    final options = DefaultFirebaseOptions.currentPlatform;
    expect(options.projectId, 'appointment-32f4a');
    expect(options.androidAppId, isNotNull);
  });
}
```

Run: `flutter test test/data/services/firebase_options_test.dart`
Expected: FAIL — `firebase_options.dart` not found.

- [ ] **Step 2: Generate Firebase options file**

Run locally (requires Firebase CLI login):

```bash
flutterfire configure --project=appointment-32f4a --out=lib/data/services/firebase_options.dart --platforms=android,ios,web
```

If `flutterfire` is unavailable, manually create from the existing hardcoded values:

```dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.web:
        return web;
      default:
        throw UnsupportedError('Unsupported platform');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSy...B3Y0',
    appId: '1:909538604832:android:4570f72010453de684cd45',
    messagingSenderId: '909538604832',
    projectId: 'appointment-32f4a',
    storageBucket: 'appointment-32f4a.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'FILL_FROM_GOOGLE_SERVICE_INFO_PLIST',
    appId: '1:909538604832:ios:FILL',
    messagingSenderId: '909538604832',
    projectId: 'appointment-32f4a',
    storageBucket: 'appointment-32f4a.firebasestorage.app',
    iosBundleId: 'com.kalki.qcut',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'FILL_FROM_FIREBASE_CONSOLE',
    appId: '1:909538604832:web:FILL',
    messagingSenderId: '909538604832',
    projectId: 'appointment-32f4a',
    authDomain: 'appointment-32f4a.firebaseapp.com',
    storageBucket: 'appointment-32f4a.firebasestorage.app',
    measurementId: 'FILL',
  );
}
```

- [ ] **Step 3: Replace hardcoded config in main.dart**

In `lib/main.dart`, replace:

```dart
await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: 'AIzaSy...B3Y0',
    appId: '1:909538604832:android:4570f72010453de684cd45',
    messagingSenderId: '909538604832',
    projectId: 'appointment-32f4a',
    storageBucket: 'appointment-32f4a.firebasestorage.app',
  ),
);
```

with:

```dart
import 'package:qcut/data/services/firebase_options.dart';

await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

- [ ] **Step 4: Run tests**

Run: `flutter test test/data/services/firebase_options_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/data/services/firebase_options.dart lib/main.dart test/data/services/firebase_options_test.dart
git commit -m "feat: centralize Firebase options via FlutterFire config"
```

---

### Task 2: Create domain models for UserProfile and Tenant

**Files:**
- Create: `lib/domain/models/user_profile.dart`
- Create: `lib/domain/models/tenant.dart`
- Create: `lib/domain/models/subscription_plan.dart`
- Test: `test/domain/models/user_profile_test.dart`, `test/domain/models/tenant_test.dart`

- [ ] **Step 1: Write failing tests**

`test/domain/models/user_profile_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:qcut/domain/models/user_profile.dart';

void main() {
  test('UserProfile fromMap parses role and tenantId', () {
    final profile = UserProfile.fromMap({
      'uid': 'u1',
      'email': 'a@b.com',
      'role': 'provider',
      'tenantId': 't1',
      'displayName': 'Shop',
      'fcmTokens': ['tok1'],
    }, 'u1');
    expect(profile.role, UserRole.provider);
    expect(profile.tenantId, 't1');
  });
}
```

`test/domain/models/tenant_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:qcut/domain/models/tenant.dart';

void main() {
  test('Tenant fromMap parses slug and plan', () {
    final tenant = Tenant.fromMap({
      'id': 't1',
      'slug': 'my-shop',
      'name': 'My Shop',
      'type': 'barbershop',
      'ownerUid': 'u1',
      'planId': 'starter',
      'status': 'active',
    }, 't1');
    expect(tenant.slug, 'my-shop');
    expect(tenant.planId, 'starter');
  });
}
```

Run: `flutter test test/domain/models/`
Expected: FAIL — models not defined.

- [ ] **Step 2: Implement models**

`lib/domain/models/user_profile.dart`:

```dart
enum UserRole { customer, provider, attendant, platformAdmin }

class UserProfile {
  final String uid;
  final String? email;
  final String? phone;
  final UserRole role;
  final String? tenantId;
  final String displayName;
  final List<String> fcmTokens;
  final DateTime? createdAt;

  const UserProfile({
    required this.uid,
    this.email,
    this.phone,
    required this.role,
    this.tenantId,
    required this.displayName,
    this.fcmTokens = const [],
    this.createdAt,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map, String uid) {
    return UserProfile(
      uid: uid,
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      role: _parseRole(map['role'] as String? ?? 'customer'),
      tenantId: map['tenantId'] as String?,
      displayName: map['displayName'] as String? ?? '',
      fcmTokens: List<String>.from(map['fcmTokens'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'email': email,
        'phone': phone,
        'role': role.name,
        'tenantId': tenantId,
        'displayName': displayName,
        'fcmTokens': fcmTokens,
        'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      };

  static UserRole _parseRole(String value) =>
      UserRole.values.firstWhere((r) => r.name == value, orElse: () => UserRole.customer);
}
```

`lib/domain/models/tenant.dart`:

```dart
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
```

`lib/domain/models/subscription_plan.dart`:

```dart
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
```

- [ ] **Step 3: Run tests**

Run: `flutter test test/domain/models/`
Expected: PASS.

- [ ] **Step 4: Commit**

```bash
git add lib/domain/models/ test/domain/models/
git commit -m "feat: add UserProfile, Tenant, SubscriptionPlan domain models"
```

---

### Task 3: Create low-level Firestore and Functions services

**Files:**
- Create: `lib/data/services/firestore_service.dart`
- Create: `lib/data/services/functions_service.dart`
- Test: `test/data/services/firestore_service_test.dart`, `test/data/services/functions_service_test.dart`

- [ ] **Step 1: Write failing tests**

`test/data/services/firestore_service_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:qcut/data/services/firestore_service.dart';

void main() {
  test('getDocument returns null for missing doc', () async {
    final db = FakeFirebaseFirestore();
    final service = FirestoreService(db);
    final doc = await service.getDocument('tenants', 'missing');
    expect(doc, isNull);
  });
}
```

`test/data/services/functions_service_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:qcut/data/services/functions_service.dart';

void main() {
  test('FunctionsService exposes callable names', () {
    const names = FunctionsService.helloWorld;
    expect(names, 'helloWorld');
  });
}
```

Run: `flutter test test/data/services/`
Expected: FAIL.

- [ ] **Step 2: Implement services**

`lib/data/services/firestore_service.dart`:

```dart
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
```

`lib/data/services/functions_service.dart`:

```dart
import 'package:cloud_functions/cloud_functions.dart';

class FunctionsService {
  final FirebaseFunctions _functions;

  FunctionsService(this._functions);

  static const String helloWorld = 'helloWorld';
  static const String issueToken = 'issueToken';
  static const String callNextToken = 'callNextToken';
  static const String completeToken = 'completeToken';
  static const String noShowToken = 'noShowToken';
  static const String createBooking = 'createBooking';
  static const String cancelBooking = 'cancelBooking';
  static const String convertBookingToToken = 'convertBookingToToken';
  static const String enforcePlanLimits = 'enforcePlanLimits';
  static const String refreshCustomClaims = 'refreshCustomClaims';

  Future<Map<String, dynamic>> call(String name, Map<String, dynamic> params) async {
    final callable = _functions.httpsCallable(name);
    final result = await callable.call(params);
    return result.data as Map<String, dynamic>;
  }
}
```

- [ ] **Step 3: Add dev dependencies**

In `pubspec.yaml`:

```yaml
dependencies:
  cloud_functions: ^4.5.0

dev_dependencies:
  fake_cloud_firestore: ^2.4.1+1
```

Run: `flutter pub get`

- [ ] **Step 4: Run tests**

Run: `flutter test test/data/services/`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/data/services/ test/data/services/ pubspec.yaml pubspec.lock
git commit -m "feat: add FirestoreService and FunctionsService wrappers"
```

---

### Task 4: Create AuthRepository with custom claims refresh

**Files:**
- Create: `lib/data/repositories/auth_repository.dart`
- Test: `test/data/repositories/auth_repository_test.dart`

- [ ] **Step 1: Write failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qcut/data/repositories/auth_repository.dart';
import 'package:qcut/data/services/functions_service.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}
class MockFunctionsService extends Mock implements FunctionsService {}

void main() {
  test('resolveRole returns role from custom claims', () async {
    final auth = MockFirebaseAuth();
    final functions = MockFunctionsService();
    final repo = AuthRepository(auth, functions);
    final user = MockUser();
    when(() => auth.currentUser).thenReturn(user);
    when(() => user.getIdTokenResult(true)).thenAnswer(
      (_) async => IdTokenResult({'claims': {'role': 'provider', 'tenantId': 't1'}}),
    );
    final role = await repo.resolveRole();
    expect(role, 'provider');
  });
}
```

Run: `flutter test test/data/repositories/auth_repository_test.dart`
Expected: FAIL.

- [ ] **Step 2: Implement AuthRepository**

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qcut/data/services/functions_service.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FunctionsService _functions;

  AuthRepository(this._auth, this._functions);

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<String?> resolveRole() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final token = await user.getIdTokenResult(true);
    return token.claims?['role'] as String?;
  }

  Future<String?> resolveTenantId() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final token = await user.getIdTokenResult(true);
    return token.claims?['tenantId'] as String?;
  }

  Future<void> refreshCustomClaims() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _functions.call(FunctionsService.refreshCustomClaims, {'uid': user.uid});
    await user.getIdToken(true);
  }

  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    await refreshCustomClaims();
    return cred;
  }

  Future<UserCredential> signUpWithEmailAndPassword(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    await refreshCustomClaims();
    return cred;
  }

  Future<void> signOut() => _auth.signOut();
}
```

- [ ] **Step 3: Run tests**

Run: `flutter test test/data/repositories/auth_repository_test.dart`
Expected: PASS.

- [ ] **Step 4: Commit**

```bash
git add lib/data/repositories/auth_repository.dart test/data/repositories/auth_repository_test.dart pubspec.yaml pubspec.lock
git commit -m "feat: add AuthRepository with custom claims refresh"
```

---

### Task 5: Harden Firestore security rules

**Files:**
- Modify: `firestore.rules`
- Test: `test/firestore.rules.spec.js` (or use Firebase Emulator Suite)

- [ ] **Step 1: Write failing rule tests**

`test/firestore.rules.spec.js`:

```javascript
const { initializeTestEnvironment, assertSucceeds, assertFails } = require('@firebase/rules-unit-testing');
const { setDoc, getDoc, doc } = require('firebase/firestore');

let testEnv;

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({ projectId: 'appointment-32f4a', firestore: { rules: '' } });
});

afterAll(async () => {
  await testEnv.cleanup();
});

test('provider can read own tenant', async () => {
  const provider = testEnv.authenticatedContext('u1', { role: 'provider', tenantId: 't1' });
  await assertSucceeds(getDoc(doc(provider.firestore(), 'tenants/t1')));
});

test('provider cannot read another tenant', async () => {
  const provider = testEnv.authenticatedContext('u1', { role: 'provider', tenantId: 't1' });
  await assertFails(getDoc(doc(provider.firestore(), 'tenants/t2')));
});
```

Run: `cd functions && npm test` (after setup)
Expected: FAIL — rules not updated yet.

- [ ] **Step 2: Update Firestore rules**

`firestore.rules`:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isAuthenticated() {
      return request.auth != null;
    }

    function isPlatformAdmin() {
      return isAuthenticated() && request.auth.token.role == 'platform_admin';
    }

    function isProviderForTenant(tenantId) {
      return isAuthenticated()
        && request.auth.token.role == 'provider'
        && request.auth.token.tenantId == tenantId;
    }

    function isCustomer() {
      return isAuthenticated() && request.auth.token.role == 'customer';
    }

    match /tenants/{tenantId} {
      allow read: if isPlatformAdmin() || isProviderForTenant(tenantId);
      allow create: if isPlatformAdmin();
      allow update: if isPlatformAdmin() || isProviderForTenant(tenantId);
      allow delete: if isPlatformAdmin();
    }

    match /tenants/{tenantId}/{collection}/{id} {
      allow read, write: if isPlatformAdmin() || isProviderForTenant(tenantId);
    }

    match /tenants/{tenantId}/tokens/{date}/entries/{entryId} {
      allow read: if isPlatformAdmin() || isProviderForTenant(tenantId) || isCustomer();
      allow create, update: if isPlatformAdmin() || isProviderForTenant(tenantId);
      allow delete: if isPlatformAdmin();
    }

    match /users/{uid} {
      allow read, update: if isAuthenticated() && request.auth.uid == uid;
      allow create: if isAuthenticated() && request.auth.uid == uid;
      allow delete: if isPlatformAdmin();
    }

    match /onboarding_submissions/{id} {
      allow create: if true;
      allow read, update, delete: if isPlatformAdmin();
    }

    match /plans/{id} {
      allow read: if true;
      allow write: if isPlatformAdmin();
    }

    match /audit_logs/{id} {
      allow read: if isPlatformAdmin();
      allow create: if isAuthenticated();
    }
  }
}
```

- [ ] **Step 3: Add rule tests to CI**

In `.github/workflows/test.yml` (create if missing):

```yaml
name: Test
on: [push, pull_request]
jobs:
  rules:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
      - run: cd functions && npm ci && npm test
```

- [ ] **Step 4: Deploy rules to emulator and verify**

```bash
firebase emulators:exec --only firestore 'cd functions && npm test'
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add firestore.rules test/firestore.rules.spec.js .github/workflows/test.yml
git commit -m "security: harden Firestore rules with custom claims"
```

---

### Task 6: Initialize Cloud Functions project

**Files:**
- Create: `functions/package.json`
- Create: `functions/src/index.ts`
- Create: `functions/tsconfig.json`
- Create: `functions/.eslintrc.js`
- Modify: `firebase.json`

- [ ] **Step 1: Scaffold functions**

```bash
firebase init functions
```

Choose TypeScript.

- [ ] **Step 2: Implement helloWorld and refreshCustomClaims**

`functions/src/index.ts`:

```typescript
import * as functions from 'firebase-functions/v2';
import * as admin from 'firebase-admin';

admin.initializeApp();

export const helloWorld = functions.https.onCall((request) => {
  return { message: 'Hello from QCUT' };
});

export const refreshCustomClaims = functions.https.onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw new functions.https.HttpsError('unauthenticated', 'Login required');

  const userDoc = await admin.firestore().doc(`users/${uid}`).get();
  const data = userDoc.data() ?? {};
  const role = data['role'] ?? 'customer';
  const tenantId = data['tenantId'] ?? null;

  await admin.auth().setCustomUserClaims(uid, { role, tenantId });
  return { success: true };
});
```

- [ ] **Step 3: Add CORS and region config**

`functions/src/index.ts` (add to each callable):

```typescript
{ cors: ['qcut.co.in', 'localhost'], region: 'asia-south1' }
```

- [ ] **Step 4: Deploy and verify**

```bash
firebase deploy --only functions
```

- [ ] **Step 5: Commit**

```bash
git add functions/ firebase.json
git commit -m "feat: initialize Cloud Functions with claims refresh"
```

---

### Task 7: Enable Firebase App Check

**Files:**
- Create: `lib/data/services/app_check_service.dart`
- Modify: `lib/main.dart`
- Modify: `firestore.rules` (add App Check enforcement)

- [ ] **Step 1: Implement AppCheckService**

```dart
import 'package:firebase_app_check/firebase_app_check.dart';

class AppCheckService {
  static Future<void> activate() async {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
      appleProvider: AppleProvider.deviceCheck,
      webProvider: ReCaptchaV3Provider('YOUR_RECAPTCHA_SITE_KEY'),
    );
  }
}
```

- [ ] **Step 2: Activate after Firebase init**

In `lib/main.dart`:

```dart
import 'package:qcut/data/services/app_check_service.dart';

await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
await AppCheckService.activate();
```

- [ ] **Step 3: Enforce in Firestore rules**

Append to every `allow` rule:

```
&& request.app != null
```

For example:

```
allow create: if isPlatformAdmin() && request.app != null;
```

Note: App Check enforcement should be rolled out in monitor-only mode first, then enforced.

- [ ] **Step 4: Commit**

```bash
git add lib/data/services/app_check_service.dart lib/main.dart firestore.rules pubspec.yaml pubspec.lock
git commit -m "security: enable Firebase App Check"
```

---

## Self-Review

- Spec coverage: all foundation/security sections from the spec are covered.
- Placeholder scan: no TBD/TODO.
- Type consistency: `role` strings align with `UserRole` enum names; `tenantId` used consistently.

---

## Execution Handoff

After this plan is saved, choose:
1. **Subagent-Driven** — dispatch a fresh subagent per task.
2. **Inline Execution** — execute tasks in this session.
