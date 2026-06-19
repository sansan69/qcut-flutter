# QCUT Branding & Native Android Feel — Design Spec

## Overview
Unify QCUT's visual identity by using the supplied purple "Q" logo across all app surfaces (Android, iOS, web) and in-app branding, while modernizing the UI with a brand-matched dark theme. Add native Android gestures and haptics so the app feels like a first-class queue-management tool.

## Goals
1. Replace default Flutter launcher icons with the QCUT logo on all platforms.
2. Show the logo on splash, onboarding/login, and app bar where appropriate.
3. Apply a cohesive dark brand theme derived from the logo colors.
4. Add Android-native gestures and haptic feedback for primary interactions.

## Brand Assets

### Source images to create from the supplied logo
| Asset | File | Background | Use |
|-------|------|------------|-----|
| App icon source | `assets/logo/icon_bg.png` | Solid dark purple `#1A1325` behind the purple "Q" | Launcher icons, splash, favicon |
| In-app logo | `assets/logo/logo_transparent.png` | Transparent | App bar, onboarding/login headers |
| Notification icon | `assets/logo/logo_notification.png` | Transparent + flattened to white silhouette | Android notification small icon |

## Icon Coverage

### Android
- Legacy launcher: `mipmap-mdpi` through `mipmap-xxxhdpi` `ic_launcher.png`.
- Adaptive launcher: `mipmap-anydpi-v26/ic_launcher.xml` + `ic_launcher_round.xml`.
  - Foreground: `drawable/ic_launcher_foreground.xml` (vectorized logo or generated PNG).
  - Background: `@color/ic_launcher_background` set to `#1A1325`.
- Round icon variant via `android:roundIcon`.
- Notification small icon: `drawable-*/ic_notification.png` (white silhouette).

### iOS
- Full `AppIcon.appiconset` (20pt–1024pt marketing) via `flutter_launcher_icons`.
- Transparent logo version is **not** used for iOS home-screen icons; use `icon_bg.png`.

### Web
- `favicon.png` (32×32/64×64).
- `icons/Icon-192.png`, `icons/Icon-512.png` for PWA.
- `icons/Icon-maskable-192.png`, `icons/Icon-maskable-512.png` for maskable adaptive PWA icons.

## In-App Branding

### Splash Screen
- Tool: `flutter_native_splash`.
- Background: `#1A1325`.
- Image: `assets/logo/icon_bg.png` centered at 200×200 logical pixels.
- Android 12+ splash API supported via `android_12` config block.

### App Bar
- Create `QLogoHeader` widget in `lib/ui/core/`.
- Uses `assets/logo/logo_transparent.png` height 32 px on the leading side or centered.
- Falls back to `Text('QCUT')` if the logo image fails to load.
- Applied to the primary authenticated screens (customer home, provider dashboard, platform admin tenant list) where a branded header improves recognition.

### Onboarding / Login
- Large centered logo at 120×120 logical pixels using `logo_transparent.png` on the brand background.
- Slogan/subtitle below in `onSurfaceVariant` color.

## Brand Theme

### Color Palette
| Token | Hex | Usage |
|-------|-----|-------|
| primary | `#6B4EE6` | Buttons, active states, key actions |
| primaryContainer | `#4A3A9E` | Filled tonal buttons, selected chips |
| onPrimary | `#FFFFFF` | Text/icons on primary |
| secondary | `#9B7BFF` | Secondary actions, highlights |
| secondaryContainer | `#2D2659` | Secondary filled surfaces |
| surface | `#0D0D12` | App background |
| surfaceContainer | `#1A1A24` | Cards, sheets, dialogs |
| surfaceContainerHigh | `#242433` | Elevated cards |
| onSurface | `#E8E6F0` | Primary text |
| onSurfaceVariant | `#9E9CB0` | Secondary/muted text |
| outline | `#3E3E52` | Dividers, borders |
| error | `#F87171` | Errors |
| success | `#4ADE80` | Success/completed tokens |
| warning | `#FBBF24` | Warnings, no-shows |

### Typography
- Keep existing font family; only adjust headline colors to `onSurface` and body to `onSurfaceVariant`.
- Use `fontWeight.w600` for CTAs.

### Components
- `ElevatedButton`/`FilledButton`: primary background, rounded 12 px.
- `OutlinedButton`: primary outline, transparent fill.
- `Card`: `surfaceContainer` with 12 px rounded corners.
- `AppBar`: transparent or `surface` with transparent logo.
- `FAB` (provider queue screen): primary.

## Native Android Gestures & Haptics

### Dependencies
- `haptic_feedback: ^0.4.0` (or use built-in `HapticFeedback` from `flutter/services` if adequate).
- Already present: `flutter_local_notifications`, `firebase_messaging`.

### Haptic mappings
| Interaction | Feedback type |
|-------------|---------------|
| Primary CTA tap (issue token, call next, book now) | `HapticFeedbackType.mediumImpact` |
| Destructive action (cancel, no-show, suspend tenant) | `HapticFeedbackType.heavyImpact` |
| Success state (token served, booking confirmed) | `HapticFeedbackType.lightImpact` |
| Error / invalid action | `HapticFeedbackType.vibrate` |
| Long-press on queue/booking card | `HapticFeedbackType.mediumImpact` |
| Pull-to-refresh release | `HapticFeedbackType.lightImpact` |
| Token called notification (foreground) | `HapticFeedbackType.vibrate` + local notification |

### Gesture mappings
- **Pull-to-refresh**: `RefreshIndicator` on tenant lists, token list, booking list.
- **Swipe actions**: `Dismissible` or `Slidable` on queue entries.
  - Swipe right → Complete token.
  - Swipe left → No-show / Cancel (with confirmation).
- **Long-press context menu**: show options on booking cards (reschedule, call, cancel).
- **Edge-swipe navigation**: where back navigation is natural (customer booking flow), rely on system back gesture; no custom interception.

## Files to Create/Modify

### New files
- `assets/logo/icon_bg.png`
- `assets/logo/logo_transparent.png`
- `assets/logo/logo_notification.png`
- `lib/ui/core/q_logo_header.dart`
- `lib/app_theme.dart` (if absent)
- `flutter_launcher_icons.yaml`
- `flutter_native_splash.yaml`

### Modified files
- `pubspec.yaml` — add assets, dev dependencies.
- `lib/main.dart` — apply theme, configure haptic channel if needed.
- `lib/main_web_booking.dart` — apply theme.
- `lib/ui/customer/web_booking_page.dart` — brand colors.
- `lib/ui/provider/onboarding_screen.dart` — add logo and theme.
- `lib/ui/provider/provider_dashboard_screen.dart` — add branded app bar, pull-to-refresh, swipe actions.
- `lib/ui/platform_admin/tenant_list_screen.dart` — branded app bar, pull-to-refresh.
- `lib/ui/customer/customer_home_screen.dart` — branded header.
- `android/app/src/main/res/values/colors.xml` — launcher background color.
- `android/app/src/main/AndroidManifest.xml` — round icon reference if needed.

## Verification Plan
1. Run `flutter pub get` and generate scripts (`flutter_launcher_icons`, `flutter_native_splash`).
2. `flutter build apk --debug` succeeds.
3. `flutter test` passes.
4. Inspect generated Android resources (all densities present).
5. Manually verify splash displays logo and branded app bar renders.

## Open Decisions
- Final icon padding/safe-zone will be tuned after first generation; 12% padding recommended.
- Adaptive icon foreground will be a generated PNG unless the logo vector can be cleanly recreated; vector fallback is acceptable if quality is high.
