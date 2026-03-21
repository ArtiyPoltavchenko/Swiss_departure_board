# Changelog

All notable changes to Swiss Departure Board.

Format: [Semantic Versioning](https://semver.org/)

## 0.3.0 — Minimal UI (2026-03-21)
- BoardScreen: geolocation → nearby stops → departure board flow
- Loading / error / data states with typed error messages
- Permission denied: button to open app settings (Geolocator.openAppSettings)
- Location disabled: button to open location settings
- API error: retry button
- StopSelector dropdown (shown only when ≥ 2 stops)
- DepartureTile: line badge (category-colored) + destination + countdown
- CountdownChip: "N min" or departing-now walk icon
- Auto-refresh every 30 s (Timer.periodic, cancelled on dispose)
- Pull-to-refresh via RefreshIndicator
- "Updated X s ago" header label
- Last selected stop persisted and restored on next launch
- version.dart bumped to 0.3.0

## 0.2.0 — Core Logic (2026-03-21)
- Models: Stop, Departure, Disruption with full fromJson / toJson
- Departure computed getters: minutesUntil, isDeparting
- TransportApi: getNearbyStops, getDepartures (dio, 10s timeout)
- DisruptionApi: getDisruptions with placeholder key (silent empty list)
- LocationService: geolocator wrapper with injectable position getter
- Preferences: SharedPreferences wrapper (last stop, count, locale)
- Custom exception hierarchy: AppException + 7 typed subclasses
- Riverpod providers: StopNotifier, departuresProvider (family), SettingsNotifier
- Unit tests: 17 tests across models and services (no real network or GPS)
- version.dart bumped to 0.2.0

## 0.1.0 — Project Skeleton (2026-03-21)
- Flutter project structure created (lib/, test/, android/, docs/)
- pubspec.yaml with all dependencies (Riverpod, dio, geolocator, home_widget, workmanager, intl)
- Placeholder files for all models, services, providers, screens, widgets
- ARB localization stubs for DE/FR/IT/EN
- version.dart as single version source of truth
- l10n.yaml configured for flutter_gen
- docs/ structure: progress, changelog, decisions, testing checklist
