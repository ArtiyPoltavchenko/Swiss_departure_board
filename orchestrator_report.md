# Orchestrator Report — Swiss Departure Board
**Generated:** 2026-03-24 (updated — phase 8 complete)
**Status:** PHASE 8 COMPLETE — smart stop selection, persistent search button, empty-state UI

---

## Project Summary

Native Android app (Flutter/Dart) showing real-time departure boards for the nearest Swiss public transport stop. Digital replica of physical station displays. No route planning, no accounts, no ads.

- **Package:** `ch.swissdeparture.swiss_departure_board`
- **Version:** `1.0.1+2` (pubspec.yaml); `lib/version.dart` reads `1.0.1` ✓
- **Branch:** `main`
- **Latest commit:** `df17ca9`
- **Min Android:** API 26 (Android 8.0)
- **Languages:** DE / FR / IT / EN (complete)

---

## Phase Completion Status

| Phase | Title | Status | Commit |
|-------|-------|--------|--------|
| 1 | Project Skeleton | ✅ Done | `eb71938` |
| 2 | Core Logic | ✅ Done | `ec4e439` |
| 3 | Minimal UI | ✅ Done | `0c455fd` |
| 4 | Full UI | ✅ Done | `8b192ec` |
| 5 | Home Screen Widget | ✅ Done | `27c445a` |
| 6 | Polish | ✅ Done | `2077523` |
| 7 | Publish / Play Store Prep | ✅ Done | `69a1f6f` |
| — | Compilation & API Alignment | ✅ Done | `a1f5829` |
| — | Build Fixes (Gradle 8.7, geolocator API) | ✅ Done | `0292382` |
| — | Flutter 3.41.5 compat (l10n, compileSdk 36, AGP/Kotlin) | ✅ Done | `27fc0d5` |
| — | compileSdk/targetSdk AGP `=` assignment syntax fix | ✅ Done | `df17ca9` |
| 8 | UX Foundations — smart stop selection, persistent search button | ✅ Done | `0af59cb` |

---

## Technology Stack

```
Flutter 3.41.5 / Dart (null-safe, strict)
State management  : flutter_riverpod ^2.5.0
HTTP              : dio ^5.4.0
Geolocation       : geolocator ^11.0.0 + geocoding ^3.0.0
Storage           : shared_preferences ^2.2.0
Widget            : home_widget ^0.6.0
Background        : workmanager ^0.6.0
Localization      : flutter_localizations + intl 0.20.2
Typography        : google_fonts ^6.1.0
Android build     : Gradle 8.7 + AGP 8.6.0 + Kotlin 2.1.0 + compileSdk 36
```

---

## File Structure (implemented)

```
swiss_departure_board/
├── pubspec.yaml                     # 1.0.1+2, cleaned deps
├── assets/icon/.gitkeep             # placeholder (icon.png must be added before release)
├── android/
│   ├── key.properties               # TEMPLATE (gitignored) — fill before build
│   └── app/
│       ├── build.gradle             # signingConfigs.release, shrinkResources, fallback debug
│       ├── proguard-rules.pro       # Flutter/Dio/OkHttp/WorkManager/home_widget keep rules
│       └── src/main/
│           ├── AndroidManifest.xml  # MainActivity, widget receiver (exported=true), WorkManager
│           ├── kotlin/.../
│           │   ├── MainActivity.kt
│           │   └── HomeWidgetProvider.kt
│           └── res/
│               ├── layout/widget_layout.xml
│               ├── xml/widget_info.xml
│               ├── drawable/        # widget_background, ic_widget_refresh, line_badge_bg
│               └── values/          # colors.xml, strings.xml, styles.xml
├── lib/
│   ├── main.dart                    # WorkManager init, widget callback, ProviderScope
│   ├── app.dart                     # ConsumerWidget, locale live-switching
│   ├── models/
│   │   ├── stop.dart                # Stop(id, name, lat, lon) + fromJson; distance via num?.toInt()
│   │   ├── departure.dart           # Departure + fromStationboardEntry; full category mapping; empty platform → null
│   │   └── disruption.dart          # Disruption + fromJson
│   ├── version.dart                 # 1.0.1 (in lib/; imported by settings_screen.dart)
│   ├── services/
│   │   ├── exceptions.dart          # AppException + 7 typed subclasses
│   │   ├── location_service.dart    # Injectable PositionGetter, getLastKnownPosition, 5s timeout
│   │   ├── transport_api.dart       # getNearbyStops, getDepartures (15s cache), searchStops, hasUpcomingDepartures
│   │   ├── disruption_api.dart      # getDisruptions; key via String.fromEnvironment('DISRUPTION_API_KEY')
│   │   ├── preferences.dart         # SharedPreferences wrapper (stop, count, locale, interval)
│   │   └── widget_service.dart      # Static BG-safe: fetch 4 deps + write SP + updateWidget
│   ├── providers/
│   │   ├── stop_provider.dart       # StopNotifier (AsyncNotifierProvider)
│   │   ├── departures_provider.dart # FutureProvider.family<List<Departure>, String>
│   │   └── settings_provider.dart   # SettingsNotifier (count, locale, refreshIntervalSeconds)
│   ├── screens/
│   │   ├── board_screen.dart        # Full board: GPS→smart stop selection→departures; offline; search overlay; anti-race token
│   │   └── settings_screen.dart     # Count/language/refresh; imports lib/version.dart
│   ├── widgets/
│   │   ├── departure_tile.dart      # Row: badge + destination + countdown + disruption badge
│   │   ├── stop_selector.dart       # Dropdown ≥2 stops + persistent search button
│   │   ├── countdown_chip.dart      # "N min" or pulsing green "Now"
│   │   └── disruption_badge.dart    # amber icon + bottom sheet
│   └── l10n/
│       ├── app_de.arb               # 41 strings, complete
│       ├── app_en.arb               # 41 strings, complete (template)
│       ├── app_fr.arb               # 41 strings, complete
│       ├── app_it.arb               # 41 strings, complete
│       ├── app_localizations.dart   # generated — do not edit
│       ├── app_localizations_de.dart
│       ├── app_localizations_en.dart
│       ├── app_localizations_fr.dart
│       └── app_localizations_it.dart
├── test/
│   ├── models/
│   │   ├── stop_test.dart           # 5 tests: parsing, missing coord, float distance, round-trip, equality
│   │   └── departure_test.dart      # 7 tests: parsing, no prognosis, past time, estimated>scheduled, empty platform, all API categories, withDisruption
│   └── services/
│       ├── location_service_test.dart # 3 tests: inject position getter, propagate timeout/permission exceptions
│       └── transport_api_test.dart  # 7 tests: getNearbyStops (200/limit/empty/connectionError), getDepartures (200/empty/timeout)
└── docs/
    ├── progress.md                  # All phases + API alignment ✅
    ├── changelog.md                 # 0.1.0 → 1.0.0 → 1.0.1
    ├── decisions.md                 # ADR-001 through ADR-017
    ├── privacy_policy.md            # GDPR-ready — needs developer name/email + hosting URL
    ├── play_store_description.md    # EN+DE full descriptions + Play Console assets checklist
    └── testing_checklist.md         # Manual QA checklist
```

---

## Key Architectural Decisions (summary)

| # | Decision | Rationale |
|---|----------|-----------|
| ADR-001 | Flutter/Dart, not Kotlin native | Single codebase, future iOS trivial; widget handled by home_widget |
| ADR-002 | Riverpod (not Provider) | Granular invalidation, no BuildContext dependency in providers |
| ADR-003 | transport.opendata.ch primary | No auth, all Switzerland, JSON, well-documented |
| ADR-004 | No backend server | Public APIs are free; no privacy/hosting concerns |
| ADR-005 | Dark theme only | Matches physical SBB boards; OLED-friendly |
| ADR-006 | Typed exception hierarchy | Context-specific UI error messages (timeout != no network != permission denied) |
| ADR-007 | Injectable PositionGetter | Tests don't need device GPS; no mockito codegen |
| ADR-008 | Custom HttpClientAdapter for tests | No build_runner needed; simpler than mockito codegen |
| ADR-011 | Widget data via SharedPreferences bridge | Standard home_widget pattern; no custom platform channel |
| ADR-012 | WidgetService as static class | WorkManager isolate has no Flutter widget tree; Riverpod unavailable |
| ADR-014 | 15s in-memory cache in TransportApi | Prevents redundant calls on screen rotate / rapid stop switching |
| ADR-015 | Disk departure cache for offline | Brief network loss shows stale data, not blank screen |
| ADR-016 | Disruption API key via `--dart-define` | Key never in source; CI injects from vault; works without key |
| ADR-017 | key.properties template committed; keystore not | Template reduces dev friction; credentials stay off git |

---

## APIs Used

| API | URL | Auth | Used For |
|-----|-----|------|----------|
| transport.opendata.ch | `https://transport.opendata.ch/v1/` | None | Nearby stops, departures |
| opentransportdata.swiss SIRI-SX | `https://api.opentransportdata.swiss/siri-sx-ch-json` | Bearer token (--dart-define) | Service disruptions |

---

## Feature List

### Main App
- GPS-based nearest stop detection (5s timeout → last-known GPS → last saved stop)
- **Smart stop selection**: parallel peek (limit=1) on all nearby stops → selects nearest with upcoming departures
- Stop selector: up to 5 closest stops, one tap to switch
- Real-time departure board with prognosis (delay) data
- Auto-refresh (configurable: 15 / 30 / 60 / 120 s)
- Pull-to-refresh (bypasses 15s API cache)
- Offline mode: disk-cached departures + amber offline banner
- **Persistent search button** (🔍) next to stop selector — always visible; opens search overlay with back button
- Manual stop search by name (300ms debounce)
- **No upcoming departures** empty state: `Icons.schedule` icon + localized message (was blank screen)
- Service disruption badges with bottom-sheet detail
- Settings: departure count (5/10/15/20), language, refresh interval
- Last stop persisted across app restarts
- Animated row slide-in + fade on refresh
- Full localization: DE / FR / IT / EN, live switching without restart

### Home Screen Widget
- 4-departure glanceable board
- Refreshes every 15 min via WorkManager (network-constrained)
- Manual refresh button via HomeWidgetBackgroundIntent
- Tap opens app (HomeWidgetLaunchIntent)
- Dark card design matching app theme

---

## Build Fixes Applied (2026-03-23)

The following blockers were resolved to get the debug APK building on this machine:

| # | Problem | Fix |
|---|---------|-----|
| 1 | `android/app/build.gradle` had stray `EOF` heredoc artifact on last line | Removed |
| 2 | Gradle 8.0 incompatible with Java 21 (class file major version 65) | Gradle wrapper 8.0 → 8.7 |
| 3 | AGP 8.1 / Kotlin 1.9.10 not tested with Gradle 8.7 | AGP → 8.3.2, Kotlin → 1.9.22 |
| 4 | `compileSdk 34` — geolocator/path_provider/shared_prefs require SDK 35 | `compileSdk 35` |
| 5 | `version.dart` at project root, not importable from inside `lib/` | Copied to `lib/version.dart`; import fixed in `settings_screen.dart` |
| 6 | `geolocator` 11.x removed `locationSettings:` from `getCurrentPosition` | Changed to `desiredAccuracy:` + `timeLimit:` in `location_service.dart` and `widget_service.dart` |
| 7 | `LocationServiceDisabledException` name clash (geolocator re-exports it; `exceptions.dart` also defines it) | Added `hide LocationServiceDisabledException` on geolocator import in `location_service.dart` and `board_screen.dart` |
| 8 | Mipmap launcher icons never committed (no `ic_launcher` / `ic_launcher_round`) | Seeded `mipmap-{mdpi…xxxhdpi}` with Flutter default icons |
| 9 | `workmanager 0.5.2` uses removed V1 Flutter embedding API (`ShimPluginRegistry`, `PluginRegistrantCallback`) | Upgraded to `workmanager 0.6.0` (highest compatible with Flutter 3.29.3) |
| 10 | `compileSdk 36` (without `=`) silently overridden back to 35 by Flutter Gradle plugin | Changed to `compileSdk = 36` + `targetSdk = 36` (AGP 8.6 assignment syntax; plugin respects `=` form) |

---

## Flutter 3.41.5 Upgrade Fixes (2026-03-24)

| # | Problem | Fix |
|---|---------|-----|
| 1 | `flutter_gen` synthetic package removed — `package:flutter_gen/gen_l10n/...` import path broken | `l10n.yaml`: `synthetic-package: false` (deprecated, removed again); import path → `package:swiss_departure_board/l10n/app_localizations.dart` in 5 files |
| 2 | Plugins (geolocator_android, path_provider_android, shared_preferences_android) require compileSdk 36 | `compileSdk 35` → `compileSdk 36` in `android/app/build.gradle` |
| 3 | AGP 8.3.2 not compatible with Flutter 3.41.5 toolchain | AGP `8.3.2` → `8.6.0` in `android/settings.gradle` |
| 4 | Kotlin 1.9.22 incompatible with AGP 8.6.0 | Kotlin `1.9.22` → `2.1.0` in `android/settings.gradle` |
| 5 | `intl ^0.19.0` incompatible with Flutter 3.41.5 intl constraints | `intl: ^0.19.0` → `intl: 0.20.2` in `pubspec.yaml` |
| 6 | Root `version.dart` dead file (never imported) | Deleted; `lib/version.dart` is the canonical copy |
| 7 | `lib/version.dart` showed `1.0.0` while `pubspec.yaml` was `1.0.1+2` | Bumped to `1.0.1` |

Generated l10n files now live in `lib/l10n/` (committed to repo alongside ARB files).

---

## Build Instructions

### Debug
```bash
flutter pub get
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk  ✅ confirmed working
```

### Run on device / emulator
```bash
flutter run
```

### Release (Google Play)
```bash
# 1. Generate keystore (once)
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# 2. Fill android/key.properties (already gitignored, template present)

# 3. Build signed AAB
flutter build appbundle --release \
  --dart-define=DISRUPTION_API_KEY=your_key

# Output: build/app/outputs/bundle/release/app-release.aab
```

---

## Tests

| File | Count | Notes |
|------|-------|-------|
| `test/models/stop_test.dart` | 5 | parsing, missing coord, float distance→int, round-trip, equality |
| `test/models/departure_test.dart` | 7 | all real API categories, empty platform, past time, estimated>scheduled |
| `test/services/location_service_test.dart` | 3 | inject fake position, propagate timeout + permission exceptions |
| `test/services/transport_api_test.dart` | 7 | HTTP 200, limit, empty, connection error, timeout |
| **Total** | **22** | No real network, no real GPS |

Run: `flutter test`

---

## Pre-Publication Checklist (human action required)

- [ ] `keytool` — generate `~/upload-keystore.jks`
- [ ] Fill `android/key.properties` with real paths + passwords
- [ ] Register at opentransportdata.swiss for free API key
- [ ] Run `flutter analyze && flutter test` in real Flutter SDK environment
- [ ] Place app icon at `assets/icon/icon.png` (1024×1024 PNG) → `flutter pub run flutter_launcher_icons`
- [ ] Capture 2+ Play Store screenshots
- [ ] Create feature graphic 1024×500 PNG
- [ ] Host `docs/privacy_policy.md` at public URL; fill developer name + email
- [ ] Create Google Play Developer account ($25 USD one-time)
- [ ] Complete Play Console content rating questionnaire (expected: PEGI 3)
- [ ] Complete Data Safety section (location → API only; no server storage)

---

## Known Limitations

- Widget uses RemoteViews only — no Flutter rendering (Android constraint, by design)
- Light theme not implemented (ADR-005: dark only)
- iOS not targeted (Android-only per project spec)
- Disruption API degrades silently without key (empty list shown)
- No crash reporting (privacy-first, no analytics)
- Flutter SDK not present in CI — `flutter analyze` and `flutter test` must be run by developer locally

---

## Git State

```
Branch  : main
Tag     : (none)
Latest  : df17ca9  fix: compileSdk = 36, targetSdk = 36 (AGP assignment syntax)
History :
  df17ca9  fix: compileSdk = 36, targetSdk = 36 (AGP assignment syntax)
  9066365  docs: update orchestrator_report.md — Flutter 3.41.5 compat
  27fc0d5  fix: Flutter 3.41.5 compat — l10n, compileSdk 36, AGP/Kotlin bump
  1ea3c0b  fix: resolve merge conflicts
  5fa8bd9  Merge branch 'main' of github.com:ArtiyPoltavchenko/Swiss_departure_board
  b9851cc  Merge pull request #2 from ArtiyPoltavchenko/claude/api-alignment-DQRCd
  0292382  fix: migrate Gradle to 8.7, fix build blockers, debug APK working
  a1f5829  fix: API contract alignment — category mapping, platform normalization, dep cleanup
```

All 7 phases + API alignment + build fixes + Flutter 3.41.5 compat committed. Working tree clean.
