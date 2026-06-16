# QCUT Scaling Spec — From MVP to 1000 Users

> Status: Draft pending implementation plan  
> Date: 2026-06-16  
> Owner: QCUT product/engineering  
> Domain: qcut.co.in

---

## 1. PRD — Product Requirements Document

### 1.1 Vision
QCUT becomes the default queue and appointment management tool for small service businesses in Kerala, India — barbershops, salons, spas, clinics, and small health centers — by replacing paper tokens and WhatsApp chaos with a simple, real-time, multi-platform app.

### 1.2 Beneficiary Definitions
Use these terms everywhere in code, UI, copy, and documentation:

| Term | Definition |
|------|------------|
| **Customer** | End user who books an appointment or joins a queue. |
| **Provider** | Shop owner/admin who runs the service business. |
| **Attendant** | Individual service provider (barber, stylist, doctor, therapist). |
| **Platform Admin** | Super admin who manages tenants, onboarding, plans, and platform operations. |

### 1.3 Goal
Transform QCUT from a working MVP into a reliable daily tool, reaching **1000 unique customers** and **1000 active Provider adoptions** within 90 days of launch.

### 1.4 Success Metrics
| Metric | Target |
|--------|--------|
| Unique customers who joined/booked | ≥ 1000 in 90 days |
| Active Providers (created tenant + processed ≥ 10 tokens/bookings) | ≥ 1000 |
| Provider DAU/MAU | ≥ 30% |
| Crash-free rate | ≥ 99.5% |
| Queue join-to-serve p95 latency on 2G/3G | ≤ 5 seconds |
| Customer notification delivery rate | ≥ 95% |

### 1.5 Problem Statements
1. **Customers** waste time standing in physical lines and never know when their turn is near.
2. **Providers** rely on paper tokens, verbal coordination, and memory — causing no-shows, queue disputes, and lost revenue.
3. **Platform Admin** has no scalable way to onboard, suspend, or manage hundreds of Providers.

### 1.6 Feature Requirements

#### Provider App
1. Live token queue screen: issue walk-in token, call next, complete, mark no-show, cancel.
2. Appointment calendar: view/advance bookings; convert a booking to a live token.
3. QR generation & share: generate shop QR and booking link `qcut.co.in/s/{shopSlug}`; share via WhatsApp/copy.
4. Attendant management: add attendants; assign services.
5. Service & settings: services, pricing, UPI, operating hours.
6. Reports: tokens served, estimated revenue, no-show rate.
7. Subscription awareness: plan limits enforced in UI and server-side.

#### Customer Experience
1. Shop discovery: scan QR or open shared link.
2. Advance appointment booking: service → date → time slot → attendant → details → confirmation.
3. Walk-in join: enter name/phone, get next available token.
4. Live status: position in queue, estimated wait, "2-away" and "your turn" notifications.
5. My bookings: upcoming/past; cancel upcoming.

#### Platform Admin
1. Tenant/shop CRUD: create, list, view, edit, suspend, delete.
2. Onboarding queue: approve/reject Provider applications.
3. Plan management: assign/upgrade/downgrade subscription plans.
4. Database reset: one-tap full wipe with typed confirmation and audit logging.

### 1.7 MoSCoW Priorities

| Priority | Items |
|----------|-------|
| Must | Real QR scanning, FCM push notifications, customer web booking page on `qcut.co.in`, iOS Firebase config, hardened Firestore rules, server-enforced plan limits, offline resilience for queue operations. |
| Should | Customer app role separation, WhatsApp share for booking links, basic analytics. |
| Could | In-app payments, multi-branch per Provider, advanced reports. |
| Won't | Full architecture rewrite to Riverpod/BLoC now; separate admin web dashboard now. |

---

## 2. TRD — Technical Requirements Document

### 2.1 Tech Stack
| Layer | Technology |
|-------|------------|
| Frontend | Flutter 3.7+ (Android, iOS, web) |
| State management | `ChangeNotifier` + `Provider` for new/refactored features; existing `setState` screens remain unless touched. |
| Backend | Firebase Auth, Cloud Firestore, Cloud Functions, Cloud Messaging, Hosting |
| Web booking page | Flutter web deployed to Vercel (`qcut.co.in`) for identical UI across platforms |
| QR scanning | `mobile_scanner` |
| Push notifications | `firebase_messaging` + `flutter_local_notifications` |
| Dependency injection | `provider` + manual service locators |

### 2.2 Architecture Overview
Introduce a layered architecture only where it reduces risk:

```
lib/
├── data/
│   ├── repositories/       # Auth, tenant, queue, booking, staff, services, notifications, plan
│   └── services/           # Low-level Firebase wrappers
├── domain/
│   └── models/             # Tenant, TokenEntry, Booking, Service, Staff, UserProfile, Plan
├── ui/
│   ├── core/               # Shared widgets, theme, localization
│   ├── auth/
│   ├── customer/
│   ├── provider/
│   └── platform_admin/
├── services/               # Existing auth/firestore services (migrated gradually)
└── main.dart
```

### 2.3 Repository Layer
Each repository exposes a small, testable interface:

- `AuthRepository` — sign in/up, role resolution, custom claims refresh, FCM token association.
- `TenantRepository` — CRUD for Provider tenant data; slug uniqueness check.
- `QueueRepository` — token issue, call next, complete, no-show, reallocation, daily meta counter.
- `BookingRepository` — advance appointments, slot availability, convert booking to token.
- `StaffRepository` — attendants/services.
- `NotificationRepository` — FCM token registration, local notification display.
- `PlanGateRepository` — fetch current plan and enforce client-side gates.

### 2.4 Server-Side Trust Boundary
Move the following to Cloud Functions to prevent client-side bypass:
- Plan limit enforcement (staff count, service count).
- Token number allocation via atomic counter.
- Queue state transitions (`waiting` → `called` → `serving` → `completed`/`no_show`).
- No-show reallocation and slot release.
- Push notification triggers on token status changes.
- Audit logging for Platform Admin destructive actions.

### 2.5 Web Booking Page
- Build with Flutter web and deploy to Vercel.
- Route: `qcut.co.in/s/{shopSlug}`.
- Public read of shop services, staff, and available slots.
- Anonymous booking/token creation via callable Cloud Function.

---

## 3. UI/UX Design

### 3.1 Design Principles
1. Mobile-first, low-end Android optimized.
2. Role-aware app shell.
3. Malayalam-first localization; all new strings added to `app_localizations.dart` in EN and ML.
4. One-tap actions for Providers.
5. Clear status for Customers.

### 3.2 Screen Map

#### Customer
- Landing / Discover
- Shop Public Page (`qcut.co.in/s/{shopSlug}`)
- Join Queue (walk-in)
- Book Appointment
- My Bookings
- Booking Detail / Live Token Status

#### Provider
- Login / Onboarding
- Dashboard
- Live Token Queue
- Appointment Calendar
- Issue Walk-in Token
- Attendant Management
- Services & Settings
- QR & Share
- Reports
- Customer History

#### Platform Admin
- Dashboard
- Tenant/Shop List
- Tenant CRUD
- Onboarding Queue
- Plan Management
- Database Reset

### 3.3 Key UX Flows
1. Customer scans QR → sees shop page → books appointment or joins queue.
2. Provider opens queue → issues walk-in token or calls next → marks complete/no-show.
3. Provider opens calendar → sees advance bookings → converts booking to token when customer arrives.
4. Customer receives "2-away" then "your turn" push notification.
5. Platform Admin approves onboarding → tenant is created → Provider logs in.

---

## 4. App Flow

### 4.1 Customer Advance Booking
1. Customer opens shared link `qcut.co.in/s/{shopSlug}` or scans QR.
2. Views shop public page: services, attendants, today's wait, "Book Appointment" CTA.
3. Selects service → date → available time slot → attendant (optional) → name + phone.
4. Confirms; system creates booking in `bookings` subcollection via callable function.
5. Customer sees confirmation and "My Bookings."

### 4.2 Walk-in Token (Provider-issued)
1. Provider opens Live Token Queue.
2. Taps "Issue Walk-in Token."
3. Enters customer name + phone (optional), selects attendant if applicable.
4. System assigns next token number and inserts into live queue.
5. Customer optionally receives token via SMS/WhatsApp or paper note.

### 4.3 Walk-in Token (Customer self-issued via QR)
1. Customer scans shop QR → opens `qcut.co.in/s/{shopSlug}`.
2. Taps "Join Queue Now."
3. Enters name + phone, selects attendant.
4. Gets token number and estimated wait.

### 4.4 Serving Queue + No-show
1. Provider taps "Call Next." Function picks oldest waiting token.
2. Provider marks "Complete" or "No-show."
3. On no-show: token status → `no_show`; system offers "Call Next" and auto-promotes next token.
4. If no-show was linked to a booking, release slot for rebooking.

### 4.5 Provider Onboarding
1. Provider fills onboarding form (business, owner, operations, review).
2. Firebase Auth account created; submission goes to `onboarding_submissions`.
3. Platform Admin approves.
4. Tenant created; Provider logs in and sees dashboard.

---

## 5. Backend Schema

### 5.1 Collections
```
tenants/{tenantId}
tenants/{tenantId}/staff/{staffId}
tenants/{tenantId}/services/{serviceId}
tenants/{tenantId}/tokens/{date}/entries/{entryId}
tenants/{tenantId}/bookings/{bookingId}
tenants/{tenantId}/customers/{customerId}
users/{uid}
onboarding_submissions/{id}
plans/{planId}
audit_logs/{id}
```

### 5.2 Document Schemas

#### `tenants/{tenantId}`
```json
{
  "id": "string",
  "slug": "unique-string",
  "name": "string",
  "type": "barbershop|salon|spa|clinic|health_center",
  "ownerUid": "string",
  "planId": "starter|pro|clinic",
  "planExpiresAt": "timestamp",
  "maxServices": "number",
  "maxStaff": "number",
  "appointmentsEnabled": "boolean",
  "qrCodeEnabled": "boolean",
  "customTimeSlots": "boolean",
  "address": { "line1": "string", "city": "string", "pincode": "string" },
  "phone": "string",
  "upiId": "string",
  "upiName": "string",
  "operatingHours": {
    "monday": { "open": "HH:MM", "close": "HH:MM", "closed": "boolean" },
    "...": "..."
  },
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "status": "active|suspended|pending"
}
```

#### `users/{uid}`
```json
{
  "uid": "string",
  "email": "string",
  "phone": "string",
  "role": "customer|provider|attendant|platform_admin",
  "tenantId": "string|null",
  "displayName": "string",
  "fcmTokens": ["string"],
  "createdAt": "timestamp"
}
```

#### `tenants/{tenantId}/tokens/{YYYY-MM-DD}/entries/{entryId}`
```json
{
  "id": "string",
  "tokenNumber": "number",
  "status": "waiting|called|serving|completed|no_show|cancelled",
  "customerName": "string",
  "customerPhone": "string",
  "staffId": "string|null",
  "serviceId": "string|null",
  "bookingId": "string|null",
  "issuedAt": "timestamp",
  "calledAt": "timestamp|null",
  "completedAt": "timestamp|null",
  "noShowAt": "timestamp|null",
  "estimatedWaitMinutes": "number",
  "source": "walk_in|web|app"
}
```

#### `tenants/{tenantId}/bookings/{bookingId}`
```json
{
  "id": "string",
  "customerName": "string",
  "customerPhone": "string",
  "serviceId": "string",
  "staffId": "string|null",
  "date": "YYYY-MM-DD",
  "timeSlot": "HH:MM",
  "status": "confirmed|completed|cancelled|no_show",
  "tokenId": "string|null",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

#### `tenants/{tenantId}/staff/{staffId}`
```json
{
  "id": "string",
  "name": "string",
  "phone": "string",
  "services": ["serviceId"],
  "isActive": "boolean",
  "role": "attendant|provider",
  "createdAt": "timestamp"
}
```

### 5.3 Indexes
```json
{
  "indexes": [
    { "collectionGroup": "bookings", "queryScope": "COLLECTION", "fields": [
      { "fieldPath": "date", "order": "ASCENDING" },
      { "fieldPath": "timeSlot", "order": "ASCENDING" }
    ]},
    { "collectionGroup": "bookings", "queryScope": "COLLECTION", "fields": [
      { "fieldPath": "status", "order": "ASCENDING" },
      { "fieldPath": "date", "order": "ASCENDING" },
      { "fieldPath": "timeSlot", "order": "ASCENDING" }
    ]},
    { "collectionGroup": "entries", "queryScope": "COLLECTION", "fields": [
      { "fieldPath": "status", "order": "ASCENDING" },
      { "fieldPath": "tokenNumber", "order": "ASCENDING" }
    ]},
    { "collectionGroup": "onboarding_submissions", "queryScope": "COLLECTION", "fields": [
      { "fieldPath": "status", "order": "ASCENDING" },
      { "fieldPath": "submittedAt", "order": "DESCENDING" }
    ]},
    { "collectionGroup": "tenants", "queryScope": "COLLECTION", "fields": [
      { "fieldPath": "slug", "order": "ASCENDING" }
    ]}
  ]
}
```

---

## 6. Algorithms & Business Logic

### 6.1 Token Number Generation
- Daily counter stored in `tenants/{tenantId}/tokens/{date}/meta.nextToken`.
- Callable Cloud Function `issueToken` atomically increments counter and creates entry to prevent duplicates.
- First token each day starts at `1`.

### 6.2 Queue Ordering & Calling Next
- Query entries ordered by `tokenNumber ASC` where `status == 'waiting'`.
- `callNext` function picks first waiting entry, updates status to `called`, records `calledAt`.
- Provider can then mark `serving` → `completed` or `no_show`.

### 6.3 No-show Reallocation
- On no-show, set status `no_show` and `noShowAt`.
- Re-query next waiting token; UI auto-offers "Call Next."
- If linked booking exists, release slot (`status = no_show` or allow reschedule).
- Optional: auto-send "your turn early" notification to promoted token.

### 6.4 Slot Availability for Advance Booking
- Generate slots from `operatingHours` + service duration.
- For each slot, count confirmed bookings + tokens with `staffId`.
- Slot available if count < capacity (default 1 per attendant per slot).
- Walk-in tokens can be issued even if slot is "full" but warn Provider.

### 6.5 Estimated Wait Time
- `estimatedWaitMinutes = position × avgServiceDuration`.
- `avgServiceDuration` computed from recent completed tokens for the tenant (default 15 min).

### 6.6 Push Triggers
- Cloud Function on token status change: when `called`, notify customer if ≤ 2 tokens ahead.
- "Your turn" notification when their token becomes current.
- FCM token stored in token entry for anonymous join; in `users/{uid}` for logged-in customers.

### 6.7 Plan Gating
- Cloud Function `enforcePlanLimits` rejects staff/service creation if over limit.
- Client pre-checks plan to show upsell UI.
- Plan fields cached in tenant document for fast reads.

---

## 7. Security Model

### 7.1 Threats
1. Cross-tenant data leakage.
2. Privilege escalation.
3. Plan limit bypass.
4. Anonymous abuse.
5. Backend secret exposure.

### 7.2 Controls
| Control | Implementation |
|---------|----------------|
| Custom claims | `role` and `tenantId` injected at login via Cloud Function; rules enforce them. |
| Firestore rules | `request.auth.token.tenantId == resource.data.tenantId`; public read only for tenant public fields. |
| Cloud Functions | Trusted enforcement for plan limits, state transitions, notifications, audit logs. |
| App Check | Play Integrity / DeviceCheck / reCAPTCHA to restrict access to genuine builds. |
| Rate limiting | Per-phone/IP limits on token/booking creation via Cloud Function. |
| Input validation | Phone, date, time, duration validation in functions. |
| Data minimization | Public shop page exposes only `name`, `slug`, `type`, `services`, `staff`, `operatingHours`. |
| Secure config | FlutterFire CLI-generated `firebase_options.dart`; dart-define for CI secrets. |
| Admin safety | Database reset requires typed confirmation and writes to `audit_logs`. |

### 7.3 Role Permissions
- **Customer** — read public tenant; create own bookings/tokens; read own bookings/tokens.
- **Provider** — full CRUD within own tenant.
- **Attendant** — read queue; update token status for assigned staff (future).
- **Platform Admin** — CRUD all tenants, approve onboarding, manage plans, reset DB.

### 7.4 Firestore Rules Principles
1. Never use `allow read, write: if request.auth != null` on subcollections.
2. Always check `request.auth.token.tenantId` matches document `tenantId`.
3. Platform Admin identified by `request.auth.token.role == 'platform_admin'`.
4. Public tenant fields read via a separate `publicTenants` collection or function-validated query.

---

## 8. Non-Functional Requirements

### 8.1 Performance
- App cold start ≤ 3 seconds on low-end Android.
- Firestore list views paginated at 50 items.
- Images compressed to ≤ 100 KB.

### 8.2 Offline
- Enable Firestore offline persistence.
- Queue reads available offline.
- Failed writes show retry state and queue locally when possible.

### 8.3 Reliability
- Cloud Functions idempotent where possible.
- All destructive actions logged to `audit_logs`.
- Daily Firestore backups enabled.

### 8.4 Localization
- All user-facing strings in English and Malayalam.
- Right-to-left not required at this stage.

### 8.5 Analytics
- Firebase Analytics events: `booking_created`, `token_issued`, `queue_completed`, `provider_onboarded`, `plan_upgraded`.
- Crashlytics for crash tracking.

---

## 9. Open Questions Resolved
1. **QR scanning scope** — QR opens the shop public page; it is not a check-in mechanism.
2. **Token vs booking** — Separate systems. Bookings can be converted to live tokens when the customer arrives.
3. **Beneficiary names** — Customer, Provider, Attendant, Platform Admin.
4. **Web domain** — `qcut.co.in` hosted on Vercel; Flutter web for identical cross-platform UI.
5. **State management** — `ChangeNotifier` + `Provider` for new/refactored features only.

---

## 10. References
- Qataar E-Queue System: https://github.com/Fiza-Khann/Qataar-E-Queue-System (QR + push + cron pattern)
- Classic Barber App: https://github.com/Lord-shaban/Classic-Barber-App (customer UX, WhatsApp integration)
- Flutter architecture case study: https://docs.flutter.dev/app-architecture/case-study (MVVM + Provider)
- Firebase security rules: https://firebase.google.com/docs/firestore/security/rules-conditions
- mobile_scanner: https://pub.dev/packages/mobile_scanner
