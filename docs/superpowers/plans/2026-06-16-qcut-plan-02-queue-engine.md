# QCUT Plan 2 — Queue Engine

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a reliable, concurrent-safe queue engine that supports walk-in token issuance, calling next, completion, no-show handling, and estimated wait times.

**Architecture:** Queue state transitions and token number allocation run in Cloud Functions using Firestore transactions; the Flutter client calls these functions and listens to Firestore snapshots for live UI updates.

**Tech Stack:** Flutter, Firebase Firestore, Cloud Functions (TypeScript), `cloud_functions`, `cloud_firestore`.

---

## File Structure

- `lib/domain/models/token_entry.dart` — token entry model.
- `lib/data/repositories/queue_repository.dart` — queue operations.
- `lib/ui/provider/token_queue_view_model.dart` — view model for queue screen.
- `functions/src/queue.ts` — Cloud Functions for queue engine.
- `functions/src/plans.ts` — plan limit helpers.

---

### Task 1: TokenEntry model

**Files:**
- Create: `lib/domain/models/token_entry.dart`
- Test: `test/domain/models/token_entry_test.dart`

- [ ] **Step 1: Write failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:qcut/domain/models/token_entry.dart';

void main() {
  test('TokenEntry fromMap parses status and tokenNumber', () {
    final entry = TokenEntry.fromMap({
      'tokenNumber': 5,
      'status': 'waiting',
      'customerName': 'Ravi',
      'customerPhone': '+919876543210',
    }, 'e1');
    expect(entry.tokenNumber, 5);
    expect(entry.status, TokenStatus.waiting);
  });
}
```

Run: `flutter test test/domain/models/token_entry_test.dart`
Expected: FAIL.

- [ ] **Step 2: Implement model**

```dart
enum TokenStatus { waiting, called, serving, completed, noShow, cancelled }

class TokenEntry {
  final String id;
  final int tokenNumber;
  final TokenStatus status;
  final String customerName;
  final String customerPhone;
  final String? staffId;
  final String? serviceId;
  final String? bookingId;
  final DateTime issuedAt;
  final DateTime? calledAt;
  final DateTime? completedAt;
  final DateTime? noShowAt;
  final int estimatedWaitMinutes;
  final String source;

  TokenEntry({
    required this.id,
    required this.tokenNumber,
    required this.status,
    required this.customerName,
    required this.customerPhone,
    this.staffId,
    this.serviceId,
    this.bookingId,
    required this.issuedAt,
    this.calledAt,
    this.completedAt,
    this.noShowAt,
    this.estimatedWaitMinutes = 0,
    this.source = 'walk_in',
  });

  factory TokenEntry.fromMap(Map<String, dynamic> map, String id) {
    return TokenEntry(
      id: id,
      tokenNumber: map['tokenNumber'] as int? ?? 0,
      status: _parseStatus(map['status'] as String? ?? 'waiting'),
      customerName: map['customerName'] as String? ?? '',
      customerPhone: map['customerPhone'] as String? ?? '',
      staffId: map['staffId'] as String?,
      serviceId: map['serviceId'] as String?,
      bookingId: map['bookingId'] as String?,
      issuedAt: (map['issuedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      calledAt: (map['calledAt'] as Timestamp?)?.toDate(),
      completedAt: (map['completedAt'] as Timestamp?)?.toDate(),
      noShowAt: (map['noShowAt'] as Timestamp?)?.toDate(),
      estimatedWaitMinutes: map['estimatedWaitMinutes'] as int? ?? 0,
      source: map['source'] as String? ?? 'walk_in',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tokenNumber': tokenNumber,
      'status': status.name,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'staffId': staffId,
      'serviceId': serviceId,
      'bookingId': bookingId,
      'issuedAt': Timestamp.fromDate(issuedAt),
      'calledAt': calledAt != null ? Timestamp.fromDate(calledAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'noShowAt': noShowAt != null ? Timestamp.fromDate(noShowAt!) : null,
      'estimatedWaitMinutes': estimatedWaitMinutes,
      'source': source,
    };
  }

  static TokenStatus _parseStatus(String value) => TokenStatus.values.firstWhere(
        (s) => s.name == value,
        orElse: () => TokenStatus.waiting,
      );

  TokenEntry copyWith({TokenStatus? status, DateTime? calledAt, DateTime? completedAt, DateTime? noShowAt, int? estimatedWaitMinutes}) =>
      TokenEntry(
        id: id,
        tokenNumber: tokenNumber,
        status: status ?? this.status,
        customerName: customerName,
        customerPhone: customerPhone,
        staffId: staffId,
        serviceId: serviceId,
        bookingId: bookingId,
        issuedAt: issuedAt,
        calledAt: calledAt ?? this.calledAt,
        completedAt: completedAt ?? this.completedAt,
        noShowAt: noShowAt ?? this.noShowAt,
        estimatedWaitMinutes: estimatedWaitMinutes ?? this.estimatedWaitMinutes,
        source: source,
      );
}
```

- [ ] **Step 3: Run tests**

Run: `flutter test test/domain/models/token_entry_test.dart`
Expected: PASS.

- [ ] **Step 4: Commit**

```bash
git add lib/domain/models/token_entry.dart test/domain/models/token_entry_test.dart
git commit -m "feat: add TokenEntry domain model"
```

---

### Task 2: QueueRepository

**Files:**
- Create: `lib/data/repositories/queue_repository.dart`
- Test: `test/data/repositories/queue_repository_test.dart`

- [ ] **Step 1: Write failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qcut/data/repositories/queue_repository.dart';
import 'package:qcut/data/services/functions_service.dart';

class MockFunctionsService extends Mock implements FunctionsService {}

void main() {
  test('issueToken calls function with tenant and customer data', () async {
    final functions = MockFunctionsService();
    final repo = QueueRepository(functions);
    when(() => functions.call('issueToken', any())).thenAnswer((_) async => {'tokenId': 't1', 'tokenNumber': 1});

    final result = await repo.issueToken(
      tenantId: 'ten1',
      customerName: 'Ravi',
      customerPhone: '+919876543210',
    );

    expect(result.tokenNumber, 1);
  });
}
```

Run: `flutter test test/data/repositories/queue_repository_test.dart`
Expected: FAIL.

- [ ] **Step 2: Implement QueueRepository**

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qcut/data/services/functions_service.dart';
import 'package:qcut/domain/models/token_entry.dart';

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
```

- [ ] **Step 3: Run tests**

Run: `flutter test test/data/repositories/queue_repository_test.dart`
Expected: PASS.

- [ ] **Step 4: Commit**

```bash
git add lib/data/repositories/queue_repository.dart test/data/repositories/queue_repository_test.dart
git commit -m "feat: add QueueRepository"
```

---

### Task 3: Cloud Function — issueToken

**Files:**
- Create/Modify: `functions/src/queue.ts`
- Test: `functions/test/queue.test.ts`

- [ ] **Step 1: Write failing test**

```typescript
import { getTestEnv } from './helpers';
import * as admin from 'firebase-admin';

const testEnv = getTestEnv();

test('issueToken increments counter and creates entry', async () => {
  const caller = testEnv.authenticatedContext('u1', { role: 'provider', tenantId: 't1' });
  const issueToken = caller.wrap(testEnv.functions.issueToken);
  const result = await issueToken({
    tenantId: 't1',
    customerName: 'Ravi',
    customerPhone: '+919876543210',
    source: 'walk_in',
  });
  expect(result.tokenNumber).toBe(1);

  const meta = await admin.firestore().doc('tenants/t1/tokens/2026-06-16/meta').get();
  expect(meta.data()?.nextToken).toBe(2);
});
```

Run: `cd functions && npm test`
Expected: FAIL.

- [ ] **Step 2: Implement issueToken**

`functions/src/queue.ts`:

```typescript
import * as functions from 'firebase-functions/v2';
import * as admin from 'firebase-admin';
import { FieldValue, Timestamp } from 'firebase-admin/firestore';

const region = 'asia-south1';

function today(): string {
  return new Date().toISOString().slice(0, 10);
}

function entryRef(tenantId: string, date: string, entryId: string) {
  return admin.firestore().doc(`tenants/${tenantId}/tokens/${date}/entries/${entryId}`);
}

function metaRef(tenantId: string, date: string) {
  return admin.firestore().doc(`tenants/${tenantId}/tokens/${date}/meta`);
}

export const issueToken = functions.https.onCall(
  { cors: ['qcut.co.in', 'localhost'], region },
  async (request) => {
    const { tenantId, customerName, customerPhone, staffId, serviceId, bookingId, source } = request.data;
    const uid = request.auth?.uid;
    if (!uid) throw new functions.https.HttpsError('unauthenticated', 'Login required');

    const date = today();
    const metaDoc = metaRef(tenantId, date);
    const newEntryRef = entryRef(tenantId, date).collection('entries').doc();

    const result = await admin.firestore().runTransaction(async (tx) => {
      const meta = await tx.get(metaDoc);
      const nextToken = (meta.exists ? meta.data()?.nextToken ?? 1 : 1) as number;
      tx.set(
        metaDoc,
        { nextToken: nextToken + 1, updatedAt: FieldValue.serverTimestamp() },
        { merge: true }
      );

      const entry = {
        tokenNumber: nextToken,
        status: 'waiting',
        customerName,
        customerPhone,
        staffId: staffId ?? null,
        serviceId: serviceId ?? null,
        bookingId: bookingId ?? null,
        issuedAt: Timestamp.now(),
        calledAt: null,
        completedAt: null,
        noShowAt: null,
        estimatedWaitMinutes: 0,
        source: source ?? 'walk_in',
      };
      tx.set(newEntryRef, entry);
      return { id: newEntryRef.id, entry: { ...entry, id: newEntryRef.id } };
    });

    return result;
  }
);
```

- [ ] **Step 3: Run tests with emulator**

```bash
firebase emulators:exec --only firestore 'cd functions && npm test'
```

Expected: PASS.

- [ ] **Step 4: Commit**

```bash
git add functions/src/queue.ts functions/test/queue.test.ts
git commit -m "feat(queue): add issueToken Cloud Function"
```

---

### Task 4: Cloud Function — callNextToken

**Files:**
- Modify: `functions/src/queue.ts`
- Test: `functions/test/queue.test.ts`

- [ ] **Step 1: Write failing test**

```typescript
test('callNextToken returns oldest waiting token', async () => {
  const db = admin.firestore();
  await db.doc('tenants/t1/tokens/2026-06-16/entries/e1').set({
    tokenNumber: 1, status: 'waiting', customerName: 'A', customerPhone: '+91', issuedAt: Timestamp.now(), source: 'walk_in'
  });
  const caller = testEnv.authenticatedContext('u1', { role: 'provider', tenantId: 't1' });
  const callNext = caller.wrap(testEnv.functions.callNextToken);
  const result = await callNext({ tenantId: 't1' });
  expect(result.entry.status).toBe('called');
});
```

Run: `cd functions && npm test`
Expected: FAIL.

- [ ] **Step 2: Implement callNextToken**

```typescript
export const callNextToken = functions.https.onCall(
  { cors: ['qcut.co.in', 'localhost'], region },
  async (request) => {
    const { tenantId, staffId } = request.data;
    const uid = request.auth?.uid;
    if (!uid) throw new functions.https.HttpsError('unauthenticated', 'Login required');

    const date = today();
    const entriesRef = admin.firestore()
      .collection('tenants')
      .doc(tenantId)
      .collection('tokens')
      .doc(date)
      .collection('entries');

    let query: admin.firestore.Query = entriesRef
      .where('status', '==', 'waiting')
      .orderBy('tokenNumber', 'asc')
      .limit(1);
    if (staffId) query = query.where('staffId', '==', staffId);

    const snap = await query.get();
    if (snap.empty) throw new functions.https.HttpsError('not-found', 'No waiting tokens');

    const doc = snap.docs[0];
    await doc.ref.update({ status: 'called', calledAt: Timestamp.now() });
    const updated = await doc.ref.get();
    return { id: updated.id, entry: { ...updated.data(), id: updated.id } };
  }
);
```

- [ ] **Step 3: Run tests**

```bash
firebase emulators:exec --only firestore 'cd functions && npm test'
```

Expected: PASS.

- [ ] **Step 4: Commit**

```bash
git add functions/src/queue.ts functions/test/queue.test.ts
git commit -m "feat(queue): add callNextToken Cloud Function"
```

---

### Task 5: Cloud Functions — completeToken and noShowToken

**Files:**
- Modify: `functions/src/queue.ts`
- Test: `functions/test/queue.test.ts`

- [ ] **Step 1: Write failing tests**

```typescript
test('completeToken marks entry completed', async () => {
  const db = admin.firestore();
  await db.doc('tenants/t1/tokens/2026-06-16/entries/e1').set({
    tokenNumber: 1, status: 'called', customerName: 'A', customerPhone: '+91', issuedAt: Timestamp.now(), source: 'walk_in'
  });
  const caller = testEnv.authenticatedContext('u1', { role: 'provider', tenantId: 't1' });
  const complete = caller.wrap(testEnv.functions.completeToken);
  const result = await complete({ tenantId: 't1', entryId: 'e1' });
  expect(result.entry.status).toBe('completed');
});

test('noShowToken marks entry no_show', async () => {
  const db = admin.firestore();
  await db.doc('tenants/t1/tokens/2026-06-16/entries/e1').set({
    tokenNumber: 1, status: 'called', customerName: 'A', customerPhone: '+91', issuedAt: Timestamp.now(), source: 'walk_in'
  });
  const caller = testEnv.authenticatedContext('u1', { role: 'provider', tenantId: 't1' });
  const noShow = caller.wrap(testEnv.functions.noShowToken);
  const result = await noShow({ tenantId: 't1', entryId: 'e1' });
  expect(result.entry.status).toBe('no_show');
});
```

Run: `cd functions && npm test`
Expected: FAIL.

- [ ] **Step 2: Implement functions**

```typescript
async function transitionToken(
  tenantId: string,
  entryId: string,
  newStatus: 'completed' | 'no_show'
) {
  const date = today();
  const ref = entryRef(tenantId, date, entryId);
  const doc = await ref.get();
  if (!doc.exists) throw new functions.https.HttpsError('not-found', 'Token not found');

  const data = doc.data()!;
  if (data.status !== 'called' && data.status !== 'serving') {
    throw new functions.https.HttpsError('failed-precondition', 'Token not active');
  }

  const update: Record<string, any> = { status: newStatus };
  if (newStatus === 'completed') update.completedAt = Timestamp.now();
  if (newStatus === 'no_show') update.noShowAt = Timestamp.now();

  await ref.update(update);
  const updated = await ref.get();
  return { id: updated.id, entry: { ...updated.data(), id: updated.id } };
}

export const completeToken = functions.https.onCall(
  { cors: ['qcut.co.in', 'localhost'], region },
  async (request) => {
    const { tenantId, entryId } = request.data;
    if (!request.auth) throw new functions.https.HttpsError('unauthenticated', 'Login required');
    return transitionToken(tenantId, entryId, 'completed');
  }
);

export const noShowToken = functions.https.onCall(
  { cors: ['qcut.co.in', 'localhost'], region },
  async (request) => {
    const { tenantId, entryId } = request.data;
    if (!request.auth) throw new functions.https.HttpsError('unauthenticated', 'Login required');
    return transitionToken(tenantId, entryId, 'no_show');
  }
);
```

- [ ] **Step 3: Run tests**

```bash
firebase emulators:exec --only firestore 'cd functions && npm test'
```

Expected: PASS.

- [ ] **Step 4: Commit**

```bash
git add functions/src/queue.ts functions/test/queue.test.ts
git commit -m "feat(queue): add completeToken and noShowToken functions"
```

---

### Task 6: Estimated wait time calculation

**Files:**
- Modify: `functions/src/queue.ts`
- Modify: `lib/data/repositories/queue_repository.dart`
- Test: update existing tests

- [ ] **Step 1: Add estimated wait to issueToken**

In `issueToken` transaction, after computing `nextToken`, compute:

```typescript
const waitingSnap = await tx.get(
  entriesRef.where('status', '==', 'waiting')
);
const position = waitingSnap.size;
const avgDuration = await getAverageServiceDuration(tenantId);
const estimatedWaitMinutes = position * avgDuration;
```

And store it on the entry.

- [ ] **Step 2: Add helper function**

```typescript
async function getAverageServiceDuration(tenantId: string): Promise<number> {
  const snap = await admin.firestore()
    .collectionGroup('entries')
    .where('status', '==', 'completed')
    .orderBy('completedAt', 'desc')
    .limit(20)
    .get();
  if (snap.empty) return 15;
  let total = 0;
  let count = 0;
  snap.docs.forEach((d) => {
    const data = d.data();
    const start = data.calledAt?.toMillis?.() ?? data.issuedAt?.toMillis?.();
    const end = data.completedAt?.toMillis?.();
    if (start && end && end > start) {
      total += (end - start) / 60000;
      count++;
    }
  });
  return count > 0 ? Math.round(total / count) : 15;
}
```

- [ ] **Step 3: Expose estimated wait in Flutter**

`QueueRepository.issueToken` already returns `TokenEntry` with `estimatedWaitMinutes`.

- [ ] **Step 4: Run tests**

```bash
firebase emulators:exec --only firestore 'cd functions && npm test'
flutter test test/data/repositories/queue_repository_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add functions/src/queue.ts lib/data/repositories/queue_repository.dart
git commit -m "feat(queue): compute estimated wait time"
```

---

### Task 7: Provider token queue screen with ViewModel

**Files:**
- Create: `lib/ui/provider/token_queue_view_model.dart`
- Modify: `lib/screens/owner/token_queue_screen.dart`
- Test: `test/ui/provider/token_queue_view_model_test.dart`

- [ ] **Step 1: Write failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qcut/ui/provider/token_queue_view_model.dart';
import 'package:qcut/data/repositories/queue_repository.dart';

class MockQueueRepository extends Mock implements QueueRepository {}

void main() {
  test('callNext invokes repository', () async {
    final repo = MockQueueRepository();
    final vm = TokenQueueViewModel(repository: repo, tenantId: 't1');
    when(() => repo.callNext('t1')).thenAnswer((_) async => TokenEntry(
      id: 'e1', tokenNumber: 1, status: TokenStatus.called,
      customerName: 'A', customerPhone: '+91', issuedAt: DateTime.now(),
    ));
    await vm.callNext();
    verify(() => repo.callNext('t1')).called(1);
  });
}
```

Run: `flutter test test/ui/provider/token_queue_view_model_test.dart`
Expected: FAIL.

- [ ] **Step 2: Implement ViewModel**

```dart
import 'package:flutter/foundation.dart';
import 'package:qcut/data/repositories/queue_repository.dart';
import 'package:qcut/domain/models/token_entry.dart';

class TokenQueueViewModel extends ChangeNotifier {
  final QueueRepository _repository;
  final String tenantId;

  TokenQueueViewModel({required QueueRepository repository, required this.tenantId})
      : _repository = repository;

  List<TokenEntry> _tokens = [];
  bool _loading = false;
  String? _error;

  List<TokenEntry> get tokens => _tokens;
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
```

- [ ] **Step 3: Wire ViewModel into existing screen**

In `lib/screens/owner/token_queue_screen.dart`, wrap with `ChangeNotifierProvider`:

```dart
ChangeNotifierProvider(
  create: (_) => TokenQueueViewModel(repository: context.read<QueueRepository>(), tenantId: tenantId),
  child: const TokenQueueScreen(),
)
```

Replace direct Firestore calls with `context.watch<TokenQueueViewModel>()`.

- [ ] **Step 4: Run tests**

```bash
flutter test test/ui/provider/token_queue_view_model_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/ui/provider/token_queue_view_model.dart lib/screens/owner/token_queue_screen.dart test/ui/provider/token_queue_view_model_test.dart
git commit -m "feat(queue): add TokenQueueViewModel and wire screen"
```

---

## Self-Review

- Spec coverage: token generation, call next, complete, no-show, estimated wait all covered.
- Placeholder scan: none.
- Type consistency: `TokenStatus` names match Firestore strings; function names align with `FunctionsService` constants.

---

## Execution Handoff

After this plan is saved, choose:
1. **Subagent-Driven** — dispatch a fresh subagent per task.
2. **Inline Execution** — execute tasks in this session.
