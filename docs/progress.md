# Progress Tracker

## Phase 1 — Skeleton
- [ ] Flutter project created
- [ ] pubspec.yaml with all dependencies
- [ ] Directory structure matches CLAUDE.md
- [ ] Placeholder files in all directories
- [ ] version.dart created
- [ ] .gitignore configured
- [ ] docs/ files created
- [ ] `flutter pub get && flutter analyze` passes

## Phase 2 — Core Logic
- [ ] Models: Stop, Departure, Disruption with fromJson
- [ ] TransportApi: getNearbyStops, getDepartures
- [ ] DisruptionApi: getDisruptions (placeholder key)
- [ ] LocationService: permission + getCurrentPosition
- [ ] Preferences: save/load settings
- [ ] Custom exception hierarchy
- [ ] Providers: StopProvider, DeparturesProvider, SettingsProvider
- [ ] Unit tests: models (3+), services (5+)
- [ ] All tests pass

## Phase 3 — Minimal UI
- [ ] BoardScreen: location → stops → departures flow
- [ ] DepartureTile: line badge + destination + countdown
- [ ] CountdownChip: minutes or "departing" icon
- [ ] StopSelector: dropdown for nearby stops
- [ ] Auto-refresh (30s timer)
- [ ] Pull-to-refresh
- [ ] Loading/error states

## Phase 4 — Full UI
- [ ] Dark Swiss theme applied
- [ ] Line badges with category colors
- [ ] Settings screen (departure count, language, refresh interval)
- [ ] Localization: DE/FR/IT/EN complete
- [ ] Disruption badges on affected departures
- [ ] Animations: fade refresh, staggered load

## Phase 5 — Widget
- [ ] widget_layout.xml — dark card, 4 departure rows
- [ ] Widget metadata (widget_info.xml)
- [ ] WidgetService: fetch + write to SharedPreferences
- [ ] WorkManager periodic task (15 min)
- [ ] Refresh button functional
- [ ] Tap widget → open app

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
