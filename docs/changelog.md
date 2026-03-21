# Changelog

All notable changes to Swiss Departure Board.

Format: [Semantic Versioning](https://semver.org/)

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
