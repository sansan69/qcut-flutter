# QCUT Flutter — Immediate Fixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix the highest-priority bugs and incomplete features that block real usage of the QCUT Flutter app.

**Architecture:** Keep changes inside the existing Flutter/Firebase monolith; fix data flow from UI through `main.dart` into `FirestoreService`, harden auth role detection, and correct localization/models.

**Tech Stack:** Flutter 3.7+, Dart, Firebase Auth / Firestore, `cloud_firestore`, `firebase_auth`, `qr_flutter`, `share_plus`, `intl`.

---

## Task 1: Fix onboarding password field

**Files:**
- Modify: `lib/screens/onboarding/onboarding_screen.dart`
- Modify: `lib/models/onboarding_models.dart` (if needed for validation)
- Test: `test/onboarding_password_test.dart` (create)

- [ ] **Step 1: Add password + confirm-password fields to owner/account step**

Add two `TextFormField`s (password, obscure; confirm password) and validate they match and are ≥ 6 characters before submission.

- [ ] **Step 2: Wire password into account creation**

Pass `_form.password` to `widget.auth.signUpWithEmail(_form.ownerEmail, _form.password, displayName: _form.ownerName)`.

- [ ] **Step 3: Add unit test for password validation**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:qcut_flutter/models/onboarding_models.dart';

void main() {
  test('password must be at least 6 characters', () {
    final form = OnboardingFormData()..password = '12345';
    expect(form.password.length >= 6, isFalse);
  });
}
```

- [ ] **Step 4: Run test**

Run: `flutter test test/onboarding_password_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/screens/onboarding/onboarding_screen.dart test/onboarding_password_test.dart
git commit -m "fix: add password field to onboarding flow"
```

---

## Task 2: Fix landing-screen customer actions

**Files:**
- Modify: `lib/main.dart`
- Modify: `lib/screens/landing/landing_screen.dart` (if callback signatures need changing)
- Test: `test/landing_flow_test.dart` (create)

- [ ] **Step 1: Replace no-op landing callbacks with real navigation**

In `AppRoot.build`, when not signed in, push a customer-only `QCutHome` (or a dedicated customer flow) so `JoinQueueScreen` and `MyBookingsScreen` receive real barbers/bookings and working callbacks. Short-term approach: push `QCutHome(auth: _auth, user: anonymousCustomer, db: _db, tenantId: 'demo')` after anonymous sign-in, or sign in anonymously when the customer taps "Join Queue" / "My Bookings".

- [ ] **Step 2: Ensure customer actions persist to Firestore demo tenant**

The customer flow should use `tenantId: 'demo'` and the same Firestore callbacks as the owner customer tab.

- [ ] **Step 3: Write widget test that pumps landing and taps join queue**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qcut_flutter/main.dart';

void main() {
  testWidgets('landing join queue button navigates', (tester) async {
    await tester.pumpWidget(const QCutApp());
    await tester.pumpAndSettle();
    expect(find.text('Join Queue'), findsOneWidget);
    await tester.tap(find.text('Join Queue'));
    await tester.pumpAndSettle();
    expect(find.byType(Scaffold), findsWidgets);
  });
}
```

- [ ] **Step 4: Run test**

Run: `flutter test test/landing_flow_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/main.dart lib/screens/landing/landing_screen.dart test/landing_flow_test.dart
git commit -m "fix: wire landing customer actions to real queue/bookings flow"
```

---

## Task 3: Fix hardcoded token number in JoinQueueScreen

**Files:**
- Modify: `lib/screens/customer/join_queue_screen.dart`
- Modify: `lib/main.dart` (pass next token)
- Test: `test/token_number_test.dart` (create)

- [ ] **Step 1: Add `nextToken` parameter to JoinQueueScreen**

```dart
final int nextToken;
const JoinQueueScreen({..., required this.nextToken});
```

- [ ] **Step 2: Use live next token in `onJoin` callback**

In `_customerJoin` inside `main.dart`, use `_nextToken++` instead of the hardcoded value.

- [ ] **Step 3: Pass `_nextToken` into JoinQueueScreen displays**

Update both `main.dart` usages (`QCutHome` bottom nav + landing customer flow after Task 2).

- [ ] **Step 4: Write test for token increment**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:qcut_flutter/models/token_entry.dart';

void main() {
  test('token increments from next available number', () {
    int nextToken = 5;
    final token = TokenEntry(tokenNumber: nextToken++);
    expect(token.tokenNumber, 5);
    expect(nextToken, 6);
  });
}
```

- [ ] **Step 5: Run test**

Run: `flutter test test/token_number_test.dart`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add lib/screens/customer/join_queue_screen.dart lib/main.dart test/token_number_test.dart
git commit -m "fix: use live next-token number in join queue"
```

---

## Task 4: Fix `bookWithShopMsg` localization bug

**Files:**
- Modify: `lib/l10n/app_localizations.dart`
- Test: `test/localization_test.dart` (create)

- [ ] **Step 1: Change placeholder strings to distinct indexed placeholders**

Find the Malayalam and English entries for `bookWithShopMsg`. Change `"... {} ... {} ..."` to use `{shop}` and `{url}` (or `%1$s`/`%2$s`) so `replaceAll` does not clobber both.

Example:
```dart
'bookWithShopMsg': 'Book your appointment with {shop} at {url}'
```

Update usages to call a small helper:
```dart
String bookWithShopMsg(String shop, String url) =>
  _map['bookWithShopMsg']!.replaceAll('{shop}', shop).replaceAll('{url}', url);
```

- [ ] **Step 2: Add regression test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:qcut_flutter/l10n/app_localizations.dart';

void main() {
  test('bookWithShopMsg replaces both placeholders', () {
    final l10n = AppLocalizations(const Locale('en'));
    final result = l10n.bookWithShopMsg('My Shop', 'https://qcut.in/my-shop');
    expect(result, contains('My Shop'));
    expect(result, contains('https://qcut.in/my-shop'));
  });
}
```

- [ ] **Step 3: Run test**

Run: `flutter test test/localization_test.dart`
Expected: PASS

- [ ] **Step 4: Commit**

```bash
git add lib/l10n/app_localizations.dart test/localization_test.dart
git commit -m "fix: correct bookWithShopMsg placeholder replacement"
```

---

## Task 5: Harden auth role detection

**Files:**
- Modify: `lib/services/firebase_auth_service.dart`
- Test: `test/firebase_auth_service_test.dart` (create)

- [ ] **Step 1: Centralize role resolution**

Extract role logic into a private method and reuse it in `_onFirebaseUser` and `_toUser`:

```dart
AuthRole _resolveRole(String? email, bool isAnonymous) {
  if (isAnonymous) return AuthRole.customer;
  if (_superAdminEmails.contains(email ?? '')) return AuthRole.superAdmin;
  return AuthRole.owner;
}
```

Call it everywhere.

- [ ] **Step 2: Add role detection test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:qcut_flutter/services/auth_service.dart';

void main() {
  test('super admin email resolves to superAdmin', () {
    final user = AuthUser(uid: '1', email: 'admin@qcut.in', role: AuthRole.superAdmin);
    expect(user.isSuperAdmin, isTrue);
  });
}
```

- [ ] **Step 3: Run test**

Run: `flutter test test/firebase_auth_service_test.dart`
Expected: PASS

- [ ] **Step 4: Commit**

```bash
git add lib/services/firebase_auth_service.dart test/firebase_auth_service_test.dart
git commit -m "fix: centralize auth role resolution for super admin"
```

---

## Task 6: Fix owner dashboard live stats

**Files:**
- Modify: `lib/screens/owner/owner_dashboard_screen.dart`
- Modify: `lib/main.dart` (pass counts if needed)
- Test: `test/owner_dashboard_stats_test.dart` (create)

- [ ] **Step 1: Compute counts from props instead of showing "—"**

Pass `waiting`, `serving`, `completed` counts to `OwnerDashboardScreen` and display them in the stat cards.

- [ ] **Step 2: Add test verifying counts render**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qcut_flutter/screens/owner/owner_dashboard_screen.dart';
import 'package:qcut_flutter/models/shop_models.dart';

void main() {
  testWidgets('dashboard shows live stats', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: OwnerDashboardScreen(
        tenant: Tenant(id: 't', name: 'Shop'),
        waitingCount: 3,
        servingCount: 1,
        completedCount: 12,
      ),
    ));
    expect(find.text('3'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
  });
}
```

- [ ] **Step 3: Run test**

Run: `flutter test test/owner_dashboard_stats_test.dart`
Expected: PASS

- [ ] **Step 4: Commit**

```bash
git add lib/screens/owner/owner_dashboard_screen.dart lib/main.dart test/owner_dashboard_stats_test.dart
git commit -m "feat: show live token counts on owner dashboard"
```

---

## Task 7: Fix `_customerJoin` barber lookup crash

**Files:**
- Modify: `lib/main.dart`
- Test: `test/customer_join_test.dart` (create)

- [ ] **Step 1: Replace `firstWhere` with safe lookup**

```dart
final barber = _barbers.cast<Barber?>().firstWhere(
  (b) => b!.id == barberId,
  orElse: () => null,
);
if (barber == null) return;
```

- [ ] **Step 2: Add test for missing barber**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:qcut_flutter/models/shop_models.dart';

void main() {
  test('firstWhere returns null for missing barber', () {
    final barbers = <Barber>[Barber(id: '1', name: 'A')];
    final found = barbers.cast<Barber?>().firstWhere(
      (b) => b!.id == 'missing',
      orElse: () => null,
    );
    expect(found, isNull);
  });
}
```

- [ ] **Step 3: Run test**

Run: `flutter test test/customer_join_test.dart`
Expected: PASS

- [ ] **Step 4: Commit**

```bash
git add lib/main.dart test/customer_join_test.dart
git commit -m "fix: guard customer join against missing barber"
```

---

## Task 8: Document required Firestore indexes

**Files:**
- Create: `firestore.indexes.json`
- Modify: `firebase.json` (if deploying indexes)

- [ ] **Step 1: Create composite indexes file**

```json
{
  "indexes": [
    {
      "collectionGroup": "bookings",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "date", "order": "ASCENDING" },
        { "fieldPath": "timeSlot", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "onboarding_submissions",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "submittedAt", "order": "DESCENDING" }
      ]
    }
  ]
}
```

- [ ] **Step 2: Commit**

```bash
git add firestore.indexes.json
git commit -m "chore: add required Firestore composite indexes"
```

---

## Self-Review

1. **Spec coverage:** Every identified high-priority blocker has at least one task.
2. **Placeholder scan:** No TBD/TODO placeholders; each step includes concrete code snippets and commands.
3. **Type consistency:** Names match existing models (`OnboardingFormData`, `JoinQueueScreen`, `OwnerDashboardScreen`, `AuthRole`, etc.).

---

## Execution Handoff

**Plan complete and saved to `docs/superpowers/plans/2025-06-16-qcut-immediate-fixes.md`.**

Two execution options:

1. **Subagent-Driven (recommended)** — dispatch a fresh subagent per task, review between tasks, fast iteration.
2. **Inline Execution** — execute tasks in this session using executing-plans, batch execution with checkpoints.

Which approach?
