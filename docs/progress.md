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

## Phase 6 — Polish
- [ ] Error handling: no internet, permission denied, GPS timeout, empty board
- [ ] Response cache (15s TTL)
- [ ] Manual stop search fallback
- [ ] README.md complete
- [ ] Testing checklist complete
- [ ] App icon configured

## Phase 7 — Publish
- [ ] Signing config in build.gradle
- [ ] API key via --dart-define
- [ ] ProGuard rules
- [ ] Privacy policy
- [ ] Play Store description draft
- [ ] Version 1.0.0
- [ ] Git tag v1.0.0
