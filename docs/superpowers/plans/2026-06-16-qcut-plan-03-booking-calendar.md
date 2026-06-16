# QCUT Plan 3 — Booking & Calendar

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement advance appointment booking with time-slot availability, booking-to-token conversion, and a Provider calendar view.

**Architecture:** Slot availability computed server-side in Cloud Functions to avoid race conditions; bookings stored as separate documents that can be converted to live tokens when the customer arrives.

**Tech Stack:** Flutter, Firebase Firestore, Cloud Functions.

---

## File Structure

- `lib/domain/models/booking.dart` — booking model.
- `lib/data/repositories/booking_repository.dart` — booking operations.
- `lib/ui/provider/calendar_view_model.dart` — Provider calendar view model.
- `lib/ui/customer/booking_view_model.dart` — customer booking flow view model.
- `functions/src/booking.ts` — booking Cloud Functions.

---

### Task 1: Booking model

**Files:**
- Create: `lib/domain/models/booking.dart`
- Test: `test/domain/models/booking_test.dart`

- [ ] **Step 1: Write failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:qcut/domain/models/booking.dart';

void main() {
  test('Booking fromMap parses date and slot', () {
    final booking = Booking.fromMap({
      'customerName': 'Ravi',
      'customerPhone': '+919876543210',
      'serviceId': 's1',
      'staffId': 'st1',
      'date': '2026-06-20',
      'timeSlot': '10:30',
      'status': 'confirmed',
    }, 'b1');
    expect(booking.date, '2026-06-20');
    expect(booking.timeSlot, '10:30');
  });
}
```

Run: `flutter test test/domain/models/booking_test.dart`
Expected: FAIL.

- [ ] **Step 2: Implement model**

```dart
enum BookingStatus { confirmed, completed, cancelled, noShow }

class Booking {
  final String id;
  final String customerName;
  final String customerPhone;
  final String serviceId;
  final String? staffId;
  final String date;
  final String timeSlot;
  final BookingStatus status;
  final String? tokenId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Booking({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.serviceId,
    this.staffId,
    required this.date,
    required this.timeSlot,
    required this.status,
    this.tokenId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Booking.fromMap(Map<String, dynamic> map, String id) {
    return Booking(
      id: id,
      customerName: map['customerName'] as String? ?? '',
      customerPhone: map['customerPhone'] as String? ?? '',
      serviceId: map['serviceId'] as String? ?? '',
      staffId: map['staffId'] as String?,
      date: map['date'] as String? ?? '',
      timeSlot: map['timeSlot'] as String? ?? '',
      status: _parseStatus(map['status'] as String? ?? 'confirmed'),
      tokenId: map['tokenId'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerName': customerName,
      'customerPhone': customerPhone,
      'serviceId': serviceId,
      'staffId': staffId,
      'date': date,
      'timeSlot': timeSlot,
      'status': status.name,
      'tokenId': tokenId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static BookingStatus _parseStatus(String value) => BookingStatus.values.firstWhere(
        (s) => s.name == value,
        orElse: () => BookingStatus.confirmed,
      );

  Booking copyWith({BookingStatus? status, String? tokenId, DateTime? updatedAt}) => Booking(
        id: id,
        customerName: customerName,
        customerPhone: customerPhone,
        serviceId: serviceId,
        staffId: staffId,
        date: date,
        timeSlot: timeSlot,
        status: status ?? this.status,
        tokenId: tokenId ?? this.tokenId,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
```

- [ ] **Step 3: Run tests**

Run: `flutter test test/domain/models/booking_test.dart`
Expected: PASS.

- [ ] **Step 4: Commit**

```bash
git add lib/domain/models/booking.dart test/domain/models/booking_test.dart
git commit -m "feat: add Booking domain model"
```

---

### Task 2: BookingRepository

**Files:**
- Create: `lib/data/repositories/booking_repository.dart`
- Test: `test/data/repositories/booking_repository_test.dart`

- [ ] **Step 1: Write failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qcut/data/repositories/booking_repository.dart';
import 'package:qcut/data/services/functions_service.dart';

class MockFunctionsService extends Mock implements FunctionsService {}

void main() {
  test('createBooking calls function', () async {
    final functions = MockFunctionsService();
    final repo = BookingRepository(functions);
    when(() => functions.call('createBooking', any())).thenAnswer((_) async => {
      'id': 'b1',
      'entry': {
        'customerName': 'Ravi', 'customerPhone': '+91', 'serviceId': 's1',
        'date': '2026-06-20', 'timeSlot': '10:30', 'status': 'confirmed',
      },
    });

    final booking = await repo.createBooking(
      tenantId: 't1', customerName: 'Ravi', customerPhone: '+91',
      serviceId: 's1', date: '2026-06-20', timeSlot: '10:30',
    );

    expect(booking.date, '2026-06-20');
  });
}
```

Run: `flutter test test/data/repositories/booking_repository_test.dart`
Expected: FAIL.

- [ ] **Step 2: Implement BookingRepository**

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qcut/data/services/functions_service.dart';
import 'package:qcut/domain/models/booking.dart';

class BookingRepository {
  final FunctionsService _functions;
  final FirebaseFirestore _firestore;

  BookingRepository(this._functions, this._firestore);

  Stream<List<Booking>> bookingsForDate(String tenantId, String date) {
    return _firestore
        .collection('tenants')
        .doc(tenantId)
        .collection('bookings')
        .where('date', isEqualTo: date)
        .orderBy('timeSlot')
        .snapshots()
        .map((snap) => snap.docs.map((d) => Booking.fromMap(d.data(), d.id)).toList());
  }

  Future<List<String>> availableSlots({
    required String tenantId,
    required String serviceId,
    required String date,
    String? staffId,
  }) async {
    final result = await _functions.call('getAvailableSlots', {
      'tenantId': tenantId,
      'serviceId': serviceId,
      'date': date,
      if (staffId != null) 'staffId': staffId,
    });
    return List<String>.from(result['slots'] as List);
  }

  Future<Booking> createBooking({
    required String tenantId,
    required String customerName,
    required String customerPhone,
    required String serviceId,
    required String date,
    required String timeSlot,
    String? staffId,
  }) async {
    final result = await _functions.call(FunctionsService.createBooking, {
      'tenantId': tenantId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'serviceId': serviceId,
      'date': date,
      'timeSlot': timeSlot,
      if (staffId != null) 'staffId': staffId,
    });
    return Booking.fromMap(result['entry'] as Map<String, dynamic>, result['id'] as String);
  }

  Future<Booking> cancelBooking(String tenantId, String bookingId) async {
    final result = await _functions.call(FunctionsService.cancelBooking, {
      'tenantId': tenantId,
      'bookingId': bookingId,
    });
    return Booking.fromMap(result['entry'] as Map<String, dynamic>, result['id'] as String);
  }

  Future<Booking> convertToToken(String tenantId, String bookingId) async {
    final result = await _functions.call(FunctionsService.convertBookingToToken, {
      'tenantId': tenantId,
      'bookingId': bookingId,
    });
    return Booking.fromMap(result['entry'] as Map<String, dynamic>, result['id'] as String);
  }
}
```

- [ ] **Step 3: Run tests**

Run: `flutter test test/data/repositories/booking_repository_test.dart`
Expected: PASS.

- [ ] **Step 4: Commit**

```bash
git add lib/data/repositories/booking_repository.dart test/data/repositories/booking_repository_test.dart
git commit -m "feat: add BookingRepository"
```

---

### Task 3: Cloud Function — getAvailableSlots

**Files:**
- Create/Modify: `functions/src/booking.ts`
- Test: `functions/test/booking.test.ts`

- [ ] **Step 1: Write failing test**

```typescript
import { getTestEnv } from './helpers';
import * as admin from 'firebase-admin';

const testEnv = getTestEnv();

test('getAvailableSlots returns slots excluding bookings', async () => {
  const db = admin.firestore();
  await db.doc('tenants/t1').set({
    operatingHours: { monday: { open: '09:00', close: '11:00', closed: false } },
  });
  await db.doc('tenants/t1/services/s1').set({ durationMinutes: 30 });
  await db.doc('tenants/t1/bookings/b1').set({ date: '2026-06-22', timeSlot: '09:00', status: 'confirmed', serviceId: 's1' });

  const caller = testEnv.authenticatedContext('u1', { role: 'customer' });
  const getSlots = caller.wrap(testEnv.functions.getAvailableSlots);
  const result = await getSlots({ tenantId: 't1', serviceId: 's1', date: '2026-06-22' });
  expect(result.slots).not.toContain('09:00');
  expect(result.slots).toContain('09:30');
});
```

Run: `cd functions && npm test`
Expected: FAIL.

- [ ] **Step 2: Implement getAvailableSlots**

`functions/src/booking.ts`:

```typescript
import * as functions from 'firebase-functions/v2';
import * as admin from 'firebase-admin';
import { Timestamp } from 'firebase-admin/firestore';

const region = 'asia-south1';

function dayOfWeek(dateStr: string): string {
  const days = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];
  return days[new Date(dateStr).getDay()];
}

function generateSlots(open: string, close: string, durationMinutes: number): string[] {
  const slots: string[] = [];
  let [h, m] = open.split(':').map(Number);
  const [endH, endM] = close.split(':').map(Number);
  const end = endH * 60 + endM;
  while (h * 60 + m + durationMinutes <= end) {
    slots.push(`${String(h).padStart(2, '0')}:${String(m).padStart(2, '0')}`);
    m += durationMinutes;
    if (m >= 60) {
      h += Math.floor(m / 60);
      m = m % 60;
    }
  }
  return slots;
}

export const getAvailableSlots = functions.https.onCall(
  { cors: ['qcut.co.in', 'localhost'], region },
  async (request) => {
    const { tenantId, serviceId, date, staffId } = request.data;

    const tenantDoc = await admin.firestore().doc(`tenants/${tenantId}`).get();
    if (!tenantDoc.exists) throw new functions.https.HttpsError('not-found', 'Tenant not found');
    const tenant = tenantDoc.data()!;
    if (!tenant.appointmentsEnabled) throw new functions.https.HttpsError('failed-precondition', 'Appointments not enabled');

    const dayKey = dayOfWeek(date);
    const hours = tenant.operatingHours?.[dayKey];
    if (!hours || hours.closed) return { slots: [] };

    const serviceDoc = await admin.firestore().doc(`tenants/${tenantId}/services/${serviceId}`).get();
    if (!serviceDoc.exists) throw new functions.https.HttpsError('not-found', 'Service not found');
    const duration = serviceDoc.data()?.durationMinutes ?? 30;

    const allSlots = generateSlots(hours.open, hours.close, duration);

    let bookingsQuery: admin.firestore.Query = admin.firestore()
      .collection(`tenants/${tenantId}/bookings`)
      .where('date', '==', date)
      .where('status', 'in', ['confirmed', 'completed']);
    if (staffId) bookingsQuery = bookingsQuery.where('staffId', '==', staffId);
    const bookings = await bookingsQuery.get();
    const bookedSlots = new Set(bookings.docs.map((d) => d.data().timeSlot));

    const tokensQuery = admin.firestore()
      .collectionGroup('entries')
      .where('bookingId', '!=', null)
      .where('status', 'in', ['waiting', 'called', 'serving']);
    // Note: collectionGroup with inequality + in may need an index; for now query per date doc.
    const dateDoc = admin.firestore().doc(`tenants/${tenantId}/tokens/${date}`);
    const tokenSnap = await dateDoc.collection('entries').where('bookingId', '!=', null).get();
    tokenSnap.docs.forEach((d) => {
      const data = d.data();
      if (['waiting', 'called', 'serving'].includes(data.status)) {
        bookedSlots.add(data.timeSlot);
      }
    });

    return { slots: allSlots.filter((s) => !bookedSlots.has(s)) };
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
git add functions/src/booking.ts functions/test/booking.test.ts
git commit -m "feat(booking): add getAvailableSlots Cloud Function"
```

---

### Task 4: Cloud Function — createBooking

**Files:**
- Modify: `functions/src/booking.ts`
- Test: `functions/test/booking.test.ts`

- [ ] **Step 1: Write failing test**

```typescript
test('createBooking stores confirmed booking', async () => {
  const caller = testEnv.authenticatedContext('u1', { role: 'customer' });
  const create = caller.wrap(testEnv.functions.createBooking);
  const result = await create({
    tenantId: 't1', customerName: 'Ravi', customerPhone: '+919876543210',
    serviceId: 's1', date: '2026-06-22', timeSlot: '09:30'
  });
  expect(result.entry.status).toBe('confirmed');
});
```

Run: `cd functions && npm test`
Expected: FAIL.

- [ ] **Step 2: Implement createBooking**

```typescript
export const createBooking = functions.https.onCall(
  { cors: ['qcut.co.in', 'localhost'], region },
  async (request) => {
    const { tenantId, customerName, customerPhone, serviceId, date, timeSlot, staffId } = request.data;

    const tenantDoc = await admin.firestore().doc(`tenants/${tenantId}`).get();
    if (!tenantDoc.exists) throw new functions.https.HttpsError('not-found', 'Tenant not found');
    if (!tenantDoc.data()!.appointmentsEnabled) {
      throw new functions.https.HttpsError('failed-precondition', 'Appointments not enabled');
    }

    const existing = await admin.firestore()
      .collection(`tenants/${tenantId}/bookings`)
      .where('date', '==', date)
      .where('timeSlot', '==', timeSlot)
      .where('status', 'in', ['confirmed', 'completed'])
      .where('staffId', '==', staffId ?? null)
      .limit(1)
      .get();
    if (!existing.empty) throw new functions.https.HttpsError('already-exists', 'Slot unavailable');

    const ref = admin.firestore().collection(`tenants/${tenantId}/bookings`).doc();
    const entry = {
      customerName,
      customerPhone,
      serviceId,
      staffId: staffId ?? null,
      date,
      timeSlot,
      status: 'confirmed',
      tokenId: null,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    };
    await ref.set(entry);
    return { id: ref.id, entry: { ...entry, id: ref.id } };
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
git add functions/src/booking.ts functions/test/booking.test.ts
git commit -m "feat(booking): add createBooking Cloud Function"
```

---

### Task 5: Cloud Functions — cancelBooking and convertBookingToToken

**Files:**
- Modify: `functions/src/booking.ts`
- Test: `functions/test/booking.test.ts`

- [ ] **Step 1: Write failing tests**

```typescript
test('cancelBooking sets status cancelled', async () => {
  const db = admin.firestore();
  await db.doc('tenants/t1/bookings/b1').set({
    customerName: 'Ravi', customerPhone: '+91', serviceId: 's1', date: '2026-06-22',
    timeSlot: '09:30', status: 'confirmed', tokenId: null,
    createdAt: Timestamp.now(), updatedAt: Timestamp.now(),
  });
  const caller = testEnv.authenticatedContext('u1', { role: 'provider', tenantId: 't1' });
  const cancel = caller.wrap(testEnv.functions.cancelBooking);
  const result = await cancel({ tenantId: 't1', bookingId: 'b1' });
  expect(result.entry.status).toBe('cancelled');
});
```

Run: `cd functions && npm test`
Expected: FAIL.

- [ ] **Step 2: Implement functions**

```typescript
export const cancelBooking = functions.https.onCall(
  { cors: ['qcut.co.in', 'localhost'], region },
  async (request) => {
    const { tenantId, bookingId } = request.data;
    if (!request.auth) throw new functions.https.HttpsError('unauthenticated', 'Login required');

    const ref = admin.firestore().doc(`tenants/${tenantId}/bookings/${bookingId}`);
    const doc = await ref.get();
    if (!doc.exists) throw new functions.https.HttpsError('not-found', 'Booking not found');

    await ref.update({ status: 'cancelled', updatedAt: Timestamp.now() });
    const updated = await ref.get();
    return { id: updated.id, entry: { ...updated.data(), id: updated.id } };
  }
);

export const convertBookingToToken = functions.https.onCall(
  { cors: ['qcut.co.in', 'localhost'], region },
  async (request) => {
    const { tenantId, bookingId } = request.data;
    if (!request.auth) throw new functions.https.HttpsError('unauthenticated', 'Login required');

    const bookingRef = admin.firestore().doc(`tenants/${tenantId}/bookings/${bookingId}`);
    const booking = await bookingRef.get();
    if (!booking.exists) throw new functions.https.HttpsError('not-found', 'Booking not found');
    const b = booking.data()!;
    if (b.status !== 'confirmed') throw new functions.https.HttpsError('failed-precondition', 'Booking not confirmed');

    const date = b.date;
    const metaDoc = admin.firestore().doc(`tenants/${tenantId}/tokens/${date}/meta`);
    const newEntryRef = admin.firestore().doc(`tenants/${tenantId}/tokens/${date}/entries`).collection('entries').doc();

    const result = await admin.firestore().runTransaction(async (tx) => {
      const meta = await tx.get(metaDoc);
      const nextToken = (meta.exists ? meta.data()?.nextToken ?? 1 : 1) as number;
      tx.set(metaDoc, { nextToken: nextToken + 1, updatedAt: Timestamp.now() }, { merge: true });

      const entry = {
        tokenNumber: nextToken,
        status: 'waiting',
        customerName: b.customerName,
        customerPhone: b.customerPhone,
        staffId: b.staffId ?? null,
        serviceId: b.serviceId,
        bookingId,
        issuedAt: Timestamp.now(),
        calledAt: null,
        completedAt: null,
        noShowAt: null,
        estimatedWaitMinutes: 0,
        source: 'app',
      };
      tx.set(newEntryRef, entry);
      tx.update(bookingRef, { tokenId: newEntryRef.id, status: 'completed', updatedAt: Timestamp.now() });
      return { id: newEntryRef.id, entry: { ...entry, id: newEntryRef.id } };
    });

    return result;
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
git add functions/src/booking.ts functions/test/booking.test.ts
git commit -m "feat(booking): add cancel and convert-to-token functions"
```

---

### Task 6: Provider Calendar ViewModel

**Files:**
- Create: `lib/ui/provider/calendar_view_model.dart`
- Modify: `lib/screens/owner/reports_screen.dart` or create `calendar_screen.dart`
- Test: `test/ui/provider/calendar_view_model_test.dart`

- [ ] **Step 1: Write failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qcut/ui/provider/calendar_view_model.dart';
import 'package:qcut/data/repositories/booking_repository.dart';

class MockBookingRepository extends Mock implements BookingRepository {}

void main() {
  test('loadDate streams bookings for selected date', () async {
    final repo = MockBookingRepository();
    final vm = CalendarViewModel(repository: repo, tenantId: 't1');
    when(() => repo.bookingsForDate('t1', any())).thenAnswer((_) => Stream.value([]));
    vm.selectDate(DateTime(2026, 6, 20));
    await Future.delayed(Duration.zero);
    verify(() => repo.bookingsForDate('t1', '2026-06-20')).called(1);
  });
}
```

Run: `flutter test test/ui/provider/calendar_view_model_test.dart`
Expected: FAIL.

- [ ] **Step 2: Implement ViewModel**

```dart
import 'package:flutter/foundation.dart';
import 'package:qcut/data/repositories/booking_repository.dart';
import 'package:qcut/domain/models/booking.dart';

class CalendarViewModel extends ChangeNotifier {
  final BookingRepository _repository;
  final String tenantId;

  CalendarViewModel({required BookingRepository repository, required this.tenantId})
      : _repository = repository;

  DateTime _selectedDate = DateTime.now();
  List<Booking> _bookings = [];
  bool _loading = false;

  DateTime get selectedDate => _selectedDate;
  List<Booking> get bookings => _bookings;
  bool get loading => _loading;

  Stream<List<Booking>>? _subscription;

  void selectDate(DateTime date) {
    _selectedDate = date;
    _subscription?.cancel();
    _subscription = _repository.bookingsForDate(tenantId, _format(date)).listen((list) {
      _bookings = list;
      notifyListeners();
    });
    notifyListeners();
  }

  Future<void> convertToToken(String bookingId) async {
    _loading = true;
    notifyListeners();
    await _repository.convertToToken(tenantId, bookingId);
    _loading = false;
    notifyListeners();
  }

  String _format(DateTime d) => d.toIso8601String().substring(0, 10);

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
```

- [ ] **Step 3: Run tests**

```bash
flutter test test/ui/provider/calendar_view_model_test.dart
```

Expected: PASS.

- [ ] **Step 4: Commit**

```bash
git add lib/ui/provider/calendar_view_model.dart test/ui/provider/calendar_view_model_test.dart
git commit -m "feat(booking): add Provider calendar view model"
```

---

## Self-Review

- Spec coverage: advance booking, slot availability, booking-to-token conversion, calendar view covered.
- Placeholder scan: none.
- Type consistency: `BookingStatus` names match Firestore strings; function names align with `FunctionsService` constants.

---

## Execution Handoff

After this plan is saved, choose:
1. **Subagent-Driven** — dispatch a fresh subagent per task.
2. **Inline Execution** — execute tasks in this session.
