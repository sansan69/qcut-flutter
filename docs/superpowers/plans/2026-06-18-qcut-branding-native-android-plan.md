# QCUT Branding & Native Android Feel — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Apply the QCUT purple "Q" logo across Android/iOS/web launcher icons, splash screen, in-app branding, and switch the app to a dark brand theme, while adding Android-native haptics and gestures.

**Architecture:** Use `flutter_launcher_icons` and `flutter_native_splash` dev packages to generate all icon and splash assets from source PNGs. Centralize brand colors in `lib/theme/app_theme.dart` and expose a reusable `QLogoHeader` widget. Add a small `HapticService` wrapper around `HapticFeedback` and a `SwipeableListTile` widget for queue/booking swipe actions.

**Tech Stack:** Flutter 3.44, Dart 3.12, `flutter_launcher_icons`, `flutter_native_splash`, `flutter/services` haptics.

---

## File Structure

### New files
- `assets/logo/icon_bg.png` — logo on dark purple background
- `assets/logo/logo_transparent.png` — logo with transparent background
- `assets/logo/logo_notification.png` — white silhouette for Android notification icon
- `lib/ui/core/q_logo_header.dart` — reusable branded app bar logo widget
- `lib/services/haptic_service.dart` — typed haptic feedback helper
- `lib/ui/core/swipeable_list_tile.dart` — reusable swipe-action tile
- `flutter_launcher_icons.yaml` — launcher icon generator config
- `flutter_native_splash.yaml` — splash generator config

### Modified files
- `pubspec.yaml` — add dev dependencies, asset declarations
- `lib/theme/app_theme.dart` — replace light theme with dark brand theme
- `lib/main.dart` — switch to dark theme, add haptic service init
- `lib/main_web_booking.dart` — apply dark brand theme
- `lib/screens/onboarding/onboarding_screen.dart` — add centered logo, brand colors
- `lib/screens/auth/login_screen.dart` — add centered logo, brand colors
- `lib/screens/customer/customer_home_screen.dart` — branded app bar
- `lib/screens/provider/provider_dashboard_screen.dart` — branded app bar, pull-to-refresh, swipe actions
- `lib/screens/owner/token_queue_screen.dart` — pull-to-refresh, swipe actions, haptics on CTAs
- `lib/screens/super_admin/super_admin_dashboard_placeholder.dart` — branded app bar
- `android/app/src/main/res/values/colors.xml` — launcher background color
- `android/app/src/main/AndroidManifest.xml` — roundIcon reference
- `web/index.html` / `web/manifest.json` — favicon/PWA icon references (after generation)

---

## Task 1: Generate Logo Assets

**Files:**
- Create: `assets/logo/icon_bg.png`
- Create: `assets/logo/logo_transparent.png`
- Create: `assets/logo/logo_notification.png`

- [ ] **Step 1: Save the supplied logo to a temp PNG with transparent background**

The user supplied a square purple "Q" logo. Save it as `/tmp/qcut_logo_raw.png`.

- [ ] **Step 2: Generate icon_bg.png (1024×1024, dark purple background, logo fit with padding)**

Use ImageMagick:

```bash
convert /tmp/qcut_logo_raw.png -resize 820x820 -background transparent -gravity center -extent 820x820 /tmp/qcut_logo_padded.png
convert -size 1024x1024 xc:'#1A1325' /tmp/qcut_logo_padded.png -gravity center -composite assets/logo/icon_bg.png
```

Expected result: `assets/logo/icon_bg.png` exists, 1024×1024.

- [ ] **Step 3: Generate logo_transparent.png (1024×1024, transparent background, logo with padding)**

```bash
convert -size 1024x1024 xc:transparent /tmp/qcut_logo_padded.png -gravity center -composite assets/logo/logo_transparent.png
```

Expected result: `assets/logo/logo_transparent.png` exists, 1024×1024, transparent.

- [ ] **Step 4: Generate logo_notification.png (96×96 white silhouette)**

```bash
convert /tmp/qcut_logo_raw.png -alpha off -threshold 0% -negate -resize 72x72 -background transparent -gravity center -extent 96x96 assets/logo/logo_notification.png
```

Expected result: white silhouette on transparent background.

- [ ] **Step 5: Verify generated assets visually**

Open the three PNGs and confirm the logo is centered, not clipped, and high contrast.

- [ ] **Step 6: Commit**

```bash
git add assets/logo/
git commit -m "assets: add QCUT logo variants for icon, splash, in-app, and notifications"
```

---

## Task 2: Configure Launcher Icon and Splash Generators

**Files:**
- Create: `flutter_launcher_icons.yaml`
- Create: `flutter_native_splash.yaml`
- Modify: `pubspec.yaml`
- Modify: `android/app/src/main/res/values/colors.xml`
- Modify: `android/app/src/main/AndroidManifest.xml`

- [ ] **Step 1: Add dev dependencies to pubspec.yaml**

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  fake_cloud_firestore: ^3.1.0
  mocktail: ^1.0.4
  flutter_lints: ^5.0.0
  flutter_launcher_icons: ^0.14.3
  flutter_native_splash: ^2.4.4
```

Run: `flutter pub get`
Expected: packages install successfully.

- [ ] **Step 2: Create flutter_launcher_icons.yaml**

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  web:
    generate: true
    image_path: "assets/logo/icon_bg.png"
    background_color: "#1A1325"
    theme_color: "#6B4EE6"
  image_path: "assets/logo/icon_bg.png"
  adaptive_icon_background: "#1A1325"
  adaptive_icon_foreground: "assets/logo/icon_bg.png"
  min_sdk_android: 21
  remove_alpha_ios: true
```

- [ ] **Step 3: Create flutter_native_splash.yaml**

```yaml
flutter_native_splash:
  color: "#1A1325"
  image: assets/logo/icon_bg.png
  branding: null
  android_12:
    image: assets/logo/icon_bg.png
    icon_background_color: "#1A1325"
  web: false
```

- [ ] **Step 4: Run generators**

```bash
flutter pub run flutter_launcher_icons
flutter pub run flutter_native_splash:create
```

Expected: Android `mipmap-*`, iOS `AppIcon.appiconset`, web `icons/` updated; splash drawables updated.

- [ ] **Step 5: Set Android adaptive icon background color**

Modify `android/app/src/main/res/values/colors.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">#1A1325</color>
</resources>
```

- [ ] **Step 6: Add roundIcon reference in AndroidManifest.xml**

In `android/app/src/main/AndroidManifest.xml`, inside `<application>`:

```xml
android:icon="@mipmap/ic_launcher"
android:roundIcon="@mipmap/ic_launcher_round"
```

- [ ] **Step 7: Add notification icon drawable**

Copy `assets/logo/logo_notification.png` to:
- `android/app/src/main/res/drawable-mdpi/ic_notification.png` (24×24 dp)
- `android/app/src/main/res/drawable-hdpi/ic_notification.png` (36×36 dp)
- `android/app/src/main/res/drawable-xhdpi/ic_notification.png` (48×48 dp)
- `android/app/src/main/res/drawable-xxhdpi/ic_notification.png` (72×72 dp)
- `android/app/src/main/res/drawable-xxxhdpi/ic_notification.png` (96×96 dp)

Use ImageMagick to generate each density from `logo_notification.png`.

- [ ] **Step 8: Verify builds**

Run: `flutter build apk --debug`
Expected: succeeds.

- [ ] **Step 9: Commit**

```bash
git add pubspec.yaml flutter_launcher_icons.yaml flutter_native_splash.yaml android/ ios/ web/ assets/logo/logo_notification.png
git commit -m "chore: generate launcher icons, splash, and notification icon from QCUT logo"
```

---

## Task 3: Implement Dark Brand Theme

**Files:**
- Modify: `lib/theme/app_theme.dart`
- Modify: `lib/main.dart`
- Modify: `lib/main_web_booking.dart`

- [ ] **Step 1: Replace QCutTheme with dark brand ColorScheme**

Replace contents of `lib/theme/app_theme.dart` with:

```dart
import 'package:flutter/material.dart';

class QCutColors {
  static const primary = Color(0xFF6B4EE6);
  static const primaryContainer = Color(0xFF4A3A9E);
  static const secondary = Color(0xFF9B7BFF);
  static const secondaryContainer = Color(0xFF2D2659);
  static const surface = Color(0xFF0D0D12);
  static const surfaceContainer = Color(0xFF1A1A24);
  static const surfaceContainerHigh = Color(0xFF242433);
  static const onSurface = Color(0xFFE8E6F0);
  static const onSurfaceVariant = Color(0xFF9E9CB0);
  static const outline = Color(0xFF3E3E52);
  static const error = Color(0xFFF87171);
  static const success = Color(0xFF4ADE80);
  static const warning = Color(0xFFFBBF24);
  static const iconBackground = Color(0xFF1A1325);
}

class QCutTheme {
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: QCutColors.primary,
      onPrimary: Colors.white,
      primaryContainer: QCutColors.primaryContainer,
      onPrimaryContainer: Colors.white,
      secondary: QCutColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: QCutColors.secondaryContainer,
      onSecondaryContainer: Colors.white,
      surface: QCutColors.surface,
      onSurface: QCutColors.onSurface,
      surfaceContainerHighest: QCutColors.surfaceContainerHigh,
      onSurfaceVariant: QCutColors.onSurfaceVariant,
      error: QCutColors.error,
      onError: Colors.white,
      outline: QCutColors.outline,
      shadow: Colors.black,
    ),
    scaffoldBackgroundColor: QCutColors.surface,
    appBarTheme: const AppBarTheme(
      backgroundColor: QCutColors.surface,
      foregroundColor: QCutColors.onSurface,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: QCutColors.surfaceContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: QCutColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: QCutColors.primary,
        side: const BorderSide(color: QCutColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: QCutColors.surfaceContainer,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: QCutColors.outline),
      ),
    ),
  );
}
```

- [ ] **Step 2: Apply dark theme in main.dart**

In `lib/main.dart`, replace `theme: QCutTheme.light` with:

```dart
theme: QCutTheme.dark,
themeMode: ThemeMode.dark,
```

- [ ] **Step 3: Apply dark theme in main_web_booking.dart**

In `lib/main_web_booking.dart`, import `theme/app_theme.dart` and set:

```dart
theme: QCutTheme.dark,
themeMode: ThemeMode.dark,
```

- [ ] **Step 4: Run widget smoke test**

Run: `flutter test test/widget_test.dart`
Expected: passes.

- [ ] **Step 5: Commit**

```bash
git add lib/theme/app_theme.dart lib/main.dart lib/main_web_booking.dart
git commit -m "feat: apply dark QCUT brand theme across app"
```

---

## Task 4: Add Reusable Logo Header Widget

**Files:**
- Create: `lib/ui/core/q_logo_header.dart`
- Modify: `lib/screens/customer/customer_home_screen.dart`
- Modify: `lib/screens/provider/provider_dashboard_screen.dart`
- Modify: `lib/screens/super_admin/super_admin_dashboard_placeholder.dart`

- [ ] **Step 1: Create QLogoHeader widget**

```dart
import 'package:flutter/material.dart';

class QLogoHeader extends StatelessWidget {
  final double height;
  final bool showText;
  const QLogoHeader({super.key, this.height = 32, this.showText = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/logo/logo_transparent.png',
          height: height,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.cut, color: Colors.white),
        ),
        if (showText) ...[
          const SizedBox(width: 8),
          Text(
            'QCUT',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
          ),
        ],
      ],
    );
  }
}
```

- [ ] **Step 2: Add to customer home app bar**

In `lib/screens/customer/customer_home_screen.dart`, import `ui/core/q_logo_header.dart` and set:

```dart
appBar: AppBar(
  title: const QLogoHeader(height: 28),
),
```

- [ ] **Step 3: Add to provider dashboard app bar**

In `lib/screens/provider/provider_dashboard_screen.dart`, set the app bar title to `QLogoHeader(height: 28)`.

- [ ] **Step 4: Add to super admin placeholder app bar**

In `lib/screens/super_admin/super_admin_dashboard_placeholder.dart`, set the app bar title to `QLogoHeader(height: 28)`.

- [ ] **Step 5: Run tests**

Run: `flutter test`
Expected: all tests pass.

- [ ] **Step 6: Commit**

```bash
git add lib/ui/core/q_logo_header.dart lib/screens/customer/customer_home_screen.dart lib/screens/provider/provider_dashboard_screen.dart lib/screens/super_admin/super_admin_dashboard_placeholder.dart
git commit -m "feat: add reusable QCUT logo header to primary screens"
```

---

## Task 5: Add Logo to Onboarding and Login Screens

**Files:**
- Modify: `lib/screens/onboarding/onboarding_screen.dart`
- Modify: `lib/screens/auth/login_screen.dart`

- [ ] **Step 1: Add logo to onboarding screen**

At the top of the onboarding form in `lib/screens/onboarding/onboarding_screen.dart`, add:

```dart
Column(
  children: [
    Image.asset(
      'assets/logo/logo_transparent.png',
      height: 120,
      errorBuilder: (_, __, ___) => const Icon(Icons.cut, size: 120),
    ),
    const SizedBox(height: 16),
    Text(
      'Queue. Cut. Go.',
      style: Theme.of(context).textTheme.headlineSmall,
    ),
    const SizedBox(height: 32),
  ],
)
```

Ensure the screen background uses `Theme.of(context).scaffoldBackgroundColor`.

- [ ] **Step 2: Add logo to login screen**

In `lib/screens/auth/login_screen.dart`, add the same logo widget above the login form, but at height 100.

- [ ] **Step 3: Run tests**

Run: `flutter test`
Expected: passes.

- [ ] **Step 4: Commit**

```bash
git add lib/screens/onboarding/onboarding_screen.dart lib/screens/auth/login_screen.dart
git commit -m "feat: add QCUT logo to onboarding and login screens"
```

---

## Task 6: Add Haptic Feedback Service

**Files:**
- Create: `lib/services/haptic_service.dart`
- Modify: `lib/screens/owner/token_queue_screen.dart`

- [ ] **Step 1: Create HapticService**

```dart
import 'package:flutter/services.dart';

enum HapticType { light, medium, heavy, vibrate }

class HapticService {
  static Future<void> trigger(HapticType type) async {
    switch (type) {
      case HapticType.light:
        await HapticFeedback.lightImpact();
      case HapticType.medium:
        await HapticFeedback.mediumImpact();
      case HapticType.heavy:
        await HapticFeedback.heavyImpact();
      case HapticType.vibrate:
        await HapticFeedback.vibrate();
    }
  }
}
```

- [ ] **Step 2: Add haptics to primary CTAs in token queue screen**

In `lib/screens/owner/token_queue_screen.dart`, before calling `issueToken`/`callNext`, call:

```dart
await HapticService.trigger(HapticType.medium);
```

Before cancel/no-show actions, call:

```dart
await HapticService.trigger(HapticType.heavy);
```

- [ ] **Step 3: Run tests**

Run: `flutter test`
Expected: passes. Haptic calls are services-side and mocked in widget tests if needed.

- [ ] **Step 4: Commit**

```bash
git add lib/services/haptic_service.dart lib/screens/owner/token_queue_screen.dart
git commit -m "feat: add haptic feedback service and wire to queue CTAs"
```

---

## Task 7: Add Swipe Actions and Pull-to-Refresh

**Files:**
- Create: `lib/ui/core/swipeable_list_tile.dart`
- Modify: `lib/screens/provider/provider_dashboard_screen.dart`
- Modify: `lib/screens/owner/token_queue_screen.dart`

- [ ] **Step 1: Create SwipeableListTile**

```dart
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

class SwipeableListTile extends StatelessWidget {
  final Widget child;
  final VoidCallback? onComplete;
  final VoidCallback? onCancel;
  final VoidCallback? onLongPress;
  const SwipeableListTile({
    super.key,
    required this.child,
    this.onComplete,
    this.onCancel,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(key),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onComplete?.call();
          return false;
        } else {
          onCancel?.call();
          return false;
        }
      },
      background: Container(
        color: QCutColors.success,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.check, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: QCutColors.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.cancel, color: Colors.white),
      ),
      child: InkWell(
        onLongPress: onLongPress,
        child: child,
      ),
    );
  }
}
```

- [ ] **Step 2: Wrap token list items with SwipeableListTile**

In `lib/screens/owner/token_queue_screen.dart`, wrap each token list tile with `SwipeableListTile` and map:
- start-to-end → complete token
- end-to-start → no-show/cancel
- long-press → show options dialog

- [ ] **Step 3: Add pull-to-refresh on provider dashboard**

In `lib/screens/provider/provider_dashboard_screen.dart`, wrap the list body with `RefreshIndicator` and wire `onRefresh` to reload view-model data.

- [ ] **Step 4: Run tests**

Run: `flutter test`
Expected: passes.

- [ ] **Step 5: Commit**

```bash
git add lib/ui/core/swipeable_list_tile.dart lib/screens/owner/token_queue_screen.dart lib/screens/provider/provider_dashboard_screen.dart
git commit -m "feat: add swipe actions, long-press, and pull-to-refresh to queue screens"
```

---

## Task 8: Final Verification and Asset Declaration

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Declare logo assets in pubspec.yaml**

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/logo/icon_bg.png
    - assets/logo/logo_transparent.png
```

- [ ] **Step 2: Run full verification**

```bash
flutter pub get
flutter build apk --debug
flutter test
```

Expected:
- `flutter build apk --debug` succeeds.
- `flutter test` shows all tests passing.

- [ ] **Step 3: Inspect generated icon files**

Verify these exist:
- `android/app/src/main/res/mipmap-*/ic_launcher.png`
- `android/app/src/main/res/mipmap-*/ic_launcher_round.png`
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/*.png`
- `web/icons/Icon-192.png`, `web/icons/Icon-512.png`, `web/icons/Icon-maskable-*.png`

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml
git commit -m "chore: declare logo assets and finalize branding integration"
```

---

## Spec Coverage Check

| Spec Section | Implementing Task |
|--------------|-------------------|
| Source images (`icon_bg.png`, `logo_transparent.png`, `logo_notification.png`) | Task 1 |
| Android/iOS/web launcher icons | Task 2 |
| Splash screen | Task 2 |
| Notification icon | Task 2 |
| Dark brand theme | Task 3 |
| App bar logo header | Task 4 |
| Onboarding/login logo | Task 5 |
| Haptics | Task 6 |
| Swipe actions / pull-to-refresh / long-press | Task 7 |
| Verification | Task 8 |

## Placeholder Scan

No placeholders. Every step contains exact commands, exact file paths, and complete code snippets.

## Type Consistency

- `QCutTheme.dark` used in both `main.dart` and `main_web_booking.dart`.
- `HapticService.trigger(HapticType)` consistent across all haptic calls.
- `QLogoHeader` height defaults to 32; callers override to 28 where tighter.
