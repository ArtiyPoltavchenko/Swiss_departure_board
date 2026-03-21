# Progress Tracker

## Phase 1 — Skeleton ✅
- [x] Flutter project created
- [x] pubspec.yaml with all dependencies
- [x] Directory structure matches CLAUDE.md
- [x] Placeholder files in all directories
- [x] version.dart created
- [x] .gitignore configured
- [x] docs/ files created
- [x] `flutter pub get && flutter analyze` ready (Flutter not installed in CI env)

## Phase 2 — Core Logic ✅
- [x] Models: Stop, Departure, Disruption with fromJson
- [x] TransportApi: getNearbyStops, getDepartures
- [x] DisruptionApi: getDisruptions (placeholder key, silent empty list)
- [x] LocationService: permission + getCurrentPosition (injectable getter)
- [x] Preferences: save/load stop, departure count, locale
- [x] Custom exception hierarchy (AppException + 7 subclasses)
- [x] Providers: StopNotifier, departuresProvider (family), SettingsNotifier
- [x] Unit tests: models (9 tests), services (8 tests) — 17 total
- [x] All tests written (require `flutter test` to verify)

## Phase 3 — Minimal UI ✅
- [x] BoardScreen: location → stops → departures flow
- [x] DepartureTile: line badge + destination + countdown
- [x] CountdownChip: minutes or "departing" icon
- [x] StopSelector: dropdown for nearby stops
- [x] Auto-refresh (30s timer)
- [x] Pull-to-refresh
- [x] Loading/error states

## Phase 4 — Full UI ✅
- [x] Dark Swiss theme applied (#1a1a2e background, gold accent)
- [x] Line badges with category colors (SBB red/blue/dark/teal/brown)
- [x] Settings screen (departure count, language, refresh interval)
- [x] Localization: DE/FR/IT/EN complete (35 strings per locale)
- [x] Disruption badges on affected departures (⚠️ + bottom sheet)
- [x] Animations: AnimatedSwitcher fade on refresh, staggered slide-in

## Phase 5 — Widget ✅
- [x] widget_layout.xml — dark card (#1a1a2e), 4 departure rows
- [x] Widget metadata (widget_info.xml, 250×110dp, 10 min OS update)
- [x] Android resources: colors.xml, strings.xml, styles.xml, drawables
- [x] HomeWidgetProvider.kt — reads SharedPreferences, populates RemoteViews
- [x] MainActivity.kt, AndroidManifest.xml (widget + WorkManager permissions)
- [x] Android build files (build.gradle × 2, settings.gradle, gradle.properties)
- [x] WidgetService: fetch + write to SharedPreferences (static, BG-safe)
- [x] WorkManager periodic task (15 min, network-constrained)
- [x] Refresh button → HomeWidgetBackgroundIntent → Dart backgroundCallback
- [x] Tap widget → HomeWidgetLaunchIntent → MainActivity

## Phase 6 — Polish ✅
- [x] transport_api.dart: 15s in-memory cache per stop ID, forceRefresh param, searchStops()
- [x] location_service.dart: timeout 15s→5s, getLastKnownPosition() fallback
- [x] board_screen.dart: offline banner + disk cache, _StopSearchView (300ms debounce), _departureToken anti-race, GPS timeout→last known GPS→last saved stop with snackbar, Tooltip on stop name
- [x] ARB files (all 4 languages): offlineDataFrom, searchStopTitle, searchStopHint, noSearchResults, usingLastLocation
- [x] pubspec.yaml: flutter_launcher_icons ^0.13.0 + assets/icon/ config
- [x] README.md: full project documentation

## Phase 7 — Publish ✅
- [x] build.gradle: signingConfigs.release from key.properties, fallback to debug, shrinkResources true
- [x] android/key.properties: template with instructions (gitignored)
- [x] proguard-rules.pro: Flutter, app classes, Dio/OkHttp, WorkManager, home_widget
- [x] pubspec.yaml version: 1.0.0+1
- [x] version.dart: 1.0.0
- [x] disruption_api.dart: API key via String.fromEnvironment('DISRUPTION_API_KEY')
- [x] docs/privacy_policy.md: full GDPR-friendly policy (location, APIs, no tracking)
- [x] docs/play_store_description.md: EN + DE full description + assets checklist
- [x] README.md: keystore generation steps + release build command with --dart-define
- [x] Git tag: v1.0.0
