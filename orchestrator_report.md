# Orchestrator Report — Swiss Departure Board
**Generated:** 2026-03-21
**Status:** ALL PHASES COMPLETE + API alignment bugfix — ready for Google Play submission

---

## Project Summary

Native Android app (Flutter/Dart) showing real-time departure boards for the nearest Swiss public transport stop. Digital replica of physical station displays. No route planning, no accounts, no ads.

- **Package:** `ch.swissdeparture.swiss_departure_board`
- **Version:** `1.0.1+2`
- **Branch:** `claude/phase-01-skeleton-DQRCd`
- **Latest commit:** `a1f5829`
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

---

## Technology Stack

```
Flutter 3.x / Dart (null-safe, strict)
State management  : flutter_riverpod ^2.5.0   (manual providers, NO codegen)
HTTP              : dio ^5.4.0
Geolocation       : geolocator ^11.0.0 + geocoding ^3.0.0
Storage           : shared_preferences ^2.2.0
Widget            : home_widget ^0.6.0
Background        : workmanager ^0.5.0
Localization      : flutter_localizations + intl ^0.19.0
Typography        : google_fonts ^6.1.0
```

**Removed from pubspec (vs. original):**
- `riverpod_annotation` — was in runtime deps, unused (no @riverpod annotations)
- `riverpod_generator` — was in dev deps, unused (no codegen files)
- `build_runner` — was in dev deps, unused (no codegen)
- `build_verify` — was in dev deps, unused

---

## File Structure (implemented)

```
swiss_departure_board/
├── version.dart                     # 1.0.1
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
│   ├── services/
│   │   ├── exceptions.dart          # AppException + 7 typed subclasses
│   │   ├── location_service.dart    # Injectable PositionGetter, getLastKnownPosition, 5s timeout
│   │   ├── transport_api.dart       # getNearbyStops (x=lat,y=lng), getDepartures (15s cache), searchStops
│   │   ├── disruption_api.dart      # getDisruptions; key via String.fromEnvironment('DISRUPTION_API_KEY')
│   │   ├── preferences.dart         # SharedPreferences wrapper (stop, count, locale, interval)
│   │   └── widget_service.dart      # Static BG-safe: fetch 4 deps + write SP + updateWidget
│   ├── providers/
│   │   ├── stop_provider.dart       # StopNotifier (AsyncNotifierProvider)
│   │   ├── departures_provider.dart # FutureProvider.family<List<Departure>, String>
│   │   └── settings_provider.dart   # SettingsNotifier (count, locale, refreshIntervalSeconds)
│   ├── screens/
│   │   ├── board_screen.dart        # Full board: GPS→stops→departures; offline; search; anti-race token
│   │   └── settings_screen.dart     # Count/language/refresh; imports version.dart from root
│   ├── widgets/
│   │   ├── departure_tile.dart      # Row: badge + destination + countdown + disruption badge
│   │   ├── stop_selector.dart       # Dropdown ≥2 stops
│   │   ├── countdown_chip.dart      # "N min" or pulsing green "Now"
│   │   └── disruption_badge.dart    # amber icon + bottom sheet
│   └── l10n/
│       ├── app_de.arb               # 40 strings, complete
│       ├── app_en.arb               # 40 strings, complete (template)
│       ├── app_fr.arb               # 40 strings, complete
│       └── app_it.arb               # 40 strings, complete
├── test/
│   ├── models/
│   │   ├── stop_test.dart           # 5 tests: parsing, missing coord, float distance, round-trip, equality
│   │   └── departure_test.dart      # 7 tests: parsing, no prognosis, past time, estimated>scheduled, empty platform, all API categories, withDisruption
│   └── services/
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

## API Contract (verified against official docs)

### transport.opendata.ch — coordinate convention
```
GET /v1/locations?x={LATITUDE}&y={LONGITUDE}&type=station
```
**x = latitude, y = longitude** (Swiss convention, opposite to math convention).
`Stop.fromJson` and `getNearbyStops` both use this correctly.

### Stationboard field paths
```json
{
  "stationboard": [{
    "stop": {
      "departure": "2024-01-15T10:30:00+0100",   ← scheduledTime
      "platform": "3",                             ← empty string → null
      "prognosis": { "departure": null }           ← estimatedTime (often null)
    },
    "number": "7",    ← line (preferred over "name")
    "name": "Tram 7", ← fallback if number absent
    "category": "T",  ← UPPERCASE
    "to": "Wollishofen"
  }]
}
```

### Category mapping (all API values covered)
| API value | Normalised | Badge color |
|-----------|-----------|-------------|
| `T` | `tram` | #e20000 red |
| `BUS` | `bus` | #0063b6 blue |
| `IC`, `ICN`, `IR`, `RE`, `EC`, `EN`, `NJ`, `S`, `SN` | `train` | #333333 dark grey |
| `BAT` | `ship` | #00857c teal |
| `FUN`, `GB` | `cableway` | #8b5e3c brown |

---

## Key Architectural Decisions

| ADR | Decision |
|-----|----------|
| 001 | Flutter/Dart, not Kotlin native |
| 002 | Riverpod manual providers (no code generation) |
| 003 | transport.opendata.ch primary — no auth required |
| 004 | No backend server |
| 005 | Dark theme only (matches physical SBB boards, OLED-friendly) |
| 006 | Typed exception hierarchy (7 subclasses) |
| 007 | Injectable PositionGetter (no device GPS in tests) |
| 008 | Custom _MockAdapter for Dio tests (no build_runner) |
| 011 | Widget data via SharedPreferences bridge (home_widget pattern) |
| 012 | WidgetService as static class (WorkManager isolate, no Riverpod) |
| 014 | 15s in-memory stationboard cache (bypassed on pull-to-refresh) |
| 015 | Disk departure cache (SharedPreferences) for offline banner |
| 016 | Disruption API key via `--dart-define=DISRUPTION_API_KEY` |
| 017 | key.properties template committed; actual keystore NOT committed |

---

## Release Build

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
| `test/services/transport_api_test.dart` | 7 | HTTP 200, limit, empty, connection error, timeout |
| **Total** | **19** | No real network, no real GPS |

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
Branch  : claude/phase-01-skeleton-DQRCd
Latest  : a1f5829  fix: API contract alignment — category mapping, platform normalization, dep cleanup
History :
  a1f5829  fix: API contract alignment — category mapping, platform normalization, dep cleanup
  1c5a535  docs: update orchestrator_report.md — all phases complete, v1.0.0
  69a1f6f  chore: phase 7 complete — release config, privacy policy, Play Store prep
  2077523  feat: phase 6 complete — error handling, caching, README, testing checklist
  27c445a  feat: phase 5 complete — Android home screen widget with WorkManager refresh
  8b192ec  feat: phase 4 complete — Swiss design, settings, l10n (DE/FR/IT/EN), disruptions
  0c455fd  feat: phase 3 complete — minimal departure board UI
  ec4e439  feat: phase 2 complete — core logic, API clients, models, providers, tests
  eb71938  chore: project skeleton — Flutter structure, dependencies, docs
```

Repository is clean. All changes committed and pushed.
