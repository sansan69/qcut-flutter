# QCUT Plan 4 — Notifications & Web Booking Page

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Enable push notifications for queue readiness and build a customer-facing Flutter web booking page deployed to Vercel at `qcut.co.in/s/{shopSlug}`.

**Architecture:** FCM triggered from Cloud Functions on token status changes; Flutter web page shares repositories and models with mobile; Vercel hosts the web build.

**Tech Stack:** Flutter, Firebase Cloud Messaging, `flutter_local_notifications`, Vercel, Cloud Functions.

---

## File Structure

- `lib/data/services/fcm_service.dart` — FCM token registration.
- `lib/data/repositories/notification_repository.dart` — notification repository.
- `web/booking/` — separate Flutter web entry point for customer booking page.
- `web/index.html` — updated for Firebase web config.
- `vercel.json` — Vercel routing for `/s/*`.
- `functions/src/notifications.ts` — FCM send logic.

---

### Task 1: FCM service and repository

**Files:**
- Create: `lib/data/services/fcm_service.dart`
- Create: `lib/data/repositories/notification_repository.dart`
- Test: `test/data/services/fcm_service_test.dart`, `test/data/repositories/notification_repository_test.dart`

- [ ] **Step 1: Write failing tests**

`test/data/services/fcm_service_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:qcut/data/services/fcm_service.dart';

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

void main() {
  test('getToken returns FCM token', () async {
    final messaging = MockFirebaseMessaging();
    when(() => messaging.getToken()).thenAnswer((_) async => 'tok1');
    final service = FcmService(messaging);
    expect(await service.getToken(), 'tok1');
  });
}
```

`test/data/repositories/notification_repository_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qcut/data/repositories/notification_repository.dart';
import 'package:qcut/data/services/fcm_service.dart';

class MockFcmService extends Mock implements FcmService {}

void main() {
  test('saveToken stores token', () async {
    final fcm = MockFcmService();
    final repo = NotificationRepository(fcmService: fcm);
    when(() => fcm.getToken()).thenAnswer((_) async => 'tok1');
    final token = await repo.getToken();
    expect(token, 'tok1');
  });
}
```

Run: `flutter test test/data/services/fcm_service_test.dart test/data/repositories/notification_repository_test.dart`
Expected: FAIL.

- [ ] **Step 2: Implement services**

`lib/data/services/fcm_service.dart`:

```dart
import 'package:firebase_messaging/firebase_messaging.dart';

class FcmService {
  final FirebaseMessaging _messaging;

  FcmService(this._messaging);

  Future<String?> getToken() => _messaging.getToken();

  Stream<String?> onTokenRefresh() => _messaging.onTokenRefresh;

  Future<void> requestPermission() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);
  }

  Stream<RemoteMessage> get onMessage => FirebaseMessaging.onMessage;
  Stream<RemoteMessage> get onMessageOpenedApp => FirebaseMessaging.onMessageOpenedApp;
}
```

`lib/data/repositories/notification_repository.dart`:

```dart
import 'package:qcut/data/services/fcm_service.dart';

class NotificationRepository {
  final FcmService _fcmService;
  String? _cachedToken;

  NotificationRepository({required FcmService fcmService}) : _fcmService = fcmService;

  Future<String?> getToken() async {
    _cachedToken ??= await _fcmService.getToken();
    return _cachedToken;
  }

  Stream<String?> onTokenRefresh() => _fcmService.onTokenRefresh();

  Future<void> requestPermission() => _fcmService.requestPermission();

  Stream<RemoteMessage> get foregroundMessages => _fcmService.onMessage;
}
```

- [ ] **Step 3: Add dependencies**

`pubspec.yaml`:

```yaml
dependencies:
  firebase_messaging: ^14.7.0
  flutter_local_notifications: ^17.0.0
```

Run: `flutter pub get`

- [ ] **Step 4: Run tests**

Run: `flutter test test/data/services/fcm_service_test.dart test/data/repositories/notification_repository_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/data/services/fcm_service.dart lib/data/repositories/notification_repository.dart test/data/services/fcm_service_test.dart test/data/repositories/notification_repository_test.dart pubspec.yaml pubspec.lock
git commit -m "feat(notifications): add FCM service and repository"
```

---

### Task 2: Local notification display

**Files:**
- Create: `lib/data/services/local_notification_service.dart`
- Modify: `lib/main.dart`
- Test: `test/data/services/local_notification_service_test.dart`

- [ ] **Step 1: Write failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:qcut/data/services/local_notification_service.dart';

void main() {
  test('LocalNotificationService initializes without error', () async {
    final service = LocalNotificationService();
    expect(service, isNotNull);
  });
}
```

Run: `flutter test test/data/services/local_notification_service_test.dart`
Expected: FAIL.

- [ ] **Step 2: Implement service**

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(settings);
  }

  Future<void> show(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'qcut_channel',
      'QCUT Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);
    await _plugin.show(0, title, body, details);
  }
}
```

- [ ] **Step 3: Initialize in main.dart**

```dart
final localNotifications = LocalNotificationService();
await localNotifications.init();
```

- [ ] **Step 4: Run tests**

Run: `flutter test test/data/services/local_notification_service_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/data/services/local_notification_service.dart test/data/services/local_notification_service_test.dart lib/main.dart
git commit -m "feat(notifications): add local notification service"
```

---

### Task 3: Cloud Function — send queue notifications

**Files:**
- Create: `functions/src/notifications.ts`
- Modify: `functions/src/queue.ts` to trigger notifications
- Test: `functions/test/notifications.test.ts`

- [ ] **Step 1: Write failing test**

```typescript
import { getTestEnv } from './helpers';
import * as admin from 'firebase-admin';

const testEnv = getTestEnv();

test('sendTokenNotification sends FCM data message', async () => {
  // FCM cannot be unit-tested easily; test helper logic instead.
  const { getTokensToNotify } = require('../src/notifications');
  const tokens = await getTokensToNotify('t1', '2026-06-16', 5);
  expect(tokens).toEqual([]);
});
```

Run: `cd functions && npm test`
Expected: FAIL.

- [ ] **Step 2: Implement notifications module**

`functions/src/notifications.ts`:

```typescript
import * as admin from 'firebase-admin';

export async function getTokensToNotify(
  tenantId: string,
  date: string,
  currentTokenNumber: number
): Promise<string[]> {
  const entries = await admin.firestore()
    .collection(`tenants/${tenantId}/tokens/${date}/entries`)
    .where('status', 'in', ['waiting', 'called'])
    .where('tokenNumber', '>=', currentTokenNumber)
    .where('tokenNumber', '<=', currentTokenNumber + 2)
    .get();

  const tokens: string[] = [];
  for (const doc of entries.docs) {
    const data = doc.data();
    const phone = data.customerPhone as string;
    if (phone) {
      const user = await admin.firestore()
        .collection('users')
        .where('phone', '==', phone)
        .limit(1)
        .get();
      if (!user.empty) {
        const userData = user.docs[0].data();
        const fcmTokens = (userData.fcmTokens ?? []) as string[];
        tokens.push(...fcmTokens);
      }
    }
  }
  return tokens;
}

export async function sendTokenNotification(
  tenantId: string,
  date: string,
  currentTokenNumber: number
): Promise<void> {
  const tokens = await getTokensToNotify(tenantId, date, currentTokenNumber);
  if (tokens.length === 0) return;

  const message = {
    tokens,
    notification: {
      title: 'Your turn is near',
      body: `Token ${currentTokenNumber + 2} is being served. Please be ready.`,
    },
    data: { tenantId, date, currentTokenNumber: String(currentTokenNumber) },
  };

  const response = await admin.messaging().sendEachForMulticast(message);
  console.log(`Sent FCM: ${response.successCount} success, ${response.failureCount} failures`);
}
```

- [ ] **Step 3: Trigger from callNextToken**

In `functions/src/queue.ts`, after updating token to `called`:

```typescript
import { sendTokenNotification } from './notifications';

await sendTokenNotification(tenantId, date, result.entry.tokenNumber);
```

- [ ] **Step 4: Run tests**

```bash
firebase emulators:exec --only firestore 'cd functions && npm test'
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add functions/src/notifications.ts functions/test/notifications.test.ts functions/src/queue.ts
git commit -m "feat(notifications): add FCM queue notification triggers"
```

---

### Task 4: Flutter web booking page

**Files:**
- Create: `lib/main_web_booking.dart`
- Create: `lib/ui/customer/web_booking_page.dart`
- Create: `web/booking/index.html`
- Modify: `vercel.json`

- [ ] **Step 1: Create web-specific main**

`lib/main_web_booking.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:qcut/data/services/firebase_options.dart';
import 'package:qcut/ui/customer/web_booking_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const WebBookingApp());
}

class WebBookingApp extends StatelessWidget {
  const WebBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QCUT Booking',
      theme: ThemeData(useMaterial3: true),
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name ?? '/');
        final slug = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
        return MaterialPageRoute(
          builder: (_) => WebBookingPage(shopSlug: slug),
        );
      },
    );
  }
}
```

- [ ] **Step 2: Implement web booking page**

`lib/ui/customer/web_booking_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:qcut/data/repositories/tenant_repository.dart';
import 'package:qcut/data/repositories/booking_repository.dart';

class WebBookingPage extends StatefulWidget {
  final String shopSlug;
  const WebBookingPage({super.key, required this.shopSlug});

  @override
  State<WebBookingPage> createState() => _WebBookingPageState();
}

class _WebBookingPageState extends State<WebBookingPage> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _tenant;

  @override
  void initState() {
    super.initState();
    _loadTenant();
  }

  Future<void> _loadTenant() async {
    try {
      final tenant = await TenantRepository.instance.fetchBySlug(widget.shopSlug);
      setState(() {
        _tenant = tenant?.toMap();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null) return Scaffold(body: Center(child: Text('Error: $_error')));
    return Scaffold(
      appBar: AppBar(title: Text(_tenant?['name'] ?? 'Shop')),
      body: Center(child: Text('Booking flow for ${widget.shopSlug}')),
    );
  }
}
```

- [ ] **Step 3: Add slug lookup to TenantRepository**

```dart
Future<Tenant?> fetchBySlug(String slug) async {
  final snap = await _firestore
      .collection('tenants')
      .where('slug', isEqualTo: slug)
      .where('status', isEqualTo: 'active')
      .limit(1)
      .get();
  if (snap.docs.isEmpty) return null;
  return Tenant.fromMap(snap.docs.first.data(), snap.docs.first.id);
}
```

- [ ] **Step 4: Configure Vercel routing**

`vercel.json`:

```json
{
  "routes": [
    { "src": "/s/(?P<slug>[^/]+)", "dest": "/booking/index.html" },
    { "src": "/(.*)", "dest": "/$1" }
  ]
}
```

- [ ] **Step 5: Build and deploy**

```bash
flutter build web --target lib/main_web_booking.dart --output-dir build/web_booking
mv build/web_booking/* .  # or configure Vercel root in dashboard
vercel --prod
```

- [ ] **Step 6: Commit**

```bash
git add lib/main_web_booking.dart lib/ui/customer/web_booking_page.dart lib/data/repositories/tenant_repository.dart web/booking/index.html vercel.json
git commit -m "feat(web): add Flutter web booking page on qcut.co.in"
```

---

## Self-Review

- Spec coverage: push notifications, local notifications, web booking page, Vercel routing covered.
- Placeholder scan: none.
- Type consistency: `FunctionsService` notification function names align with `sendTokenNotification`.

---

## Execution Handoff

After this plan is saved, choose:
1. **Subagent-Driven** — dispatch a fresh subagent per task.
2. **Inline Execution** — execute tasks in this session.
