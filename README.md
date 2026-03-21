# Swiss Departure Board

Real-time departure information for every public transport stop in Switzerland.
Open the app, see the next departures from the nearest stop — no route planning,
no accounts, no friction.

## Features

- **Nearest stop automatically** — uses your GPS location to find the closest stop
- **Real-time board** — live countdowns with delay information from operator prognosis
- **All modes** — tram, bus, train, ship, cableway
- **Disruption alerts** — warning badge when active disruptions affect your line
- **Stop selector** — switch between nearby stops from a dropdown
- **Home screen widget** — 4-departure glanceable widget, updates every 15 minutes
- **Offline fallback** — shows last cached data with timestamp when no network
- **Stop search** — manual search by name when location is unavailable
- **4 languages** — German, French, Italian, English (follows system locale)
- **Settings** — configurable departure count, auto-refresh interval, language override

## Screenshots

*Screenshots coming soon*

## Data Sources

| Source | Usage |
|--------|-------|
| [transport.opendata.ch](https://transport.opendata.ch) | Departure boards, nearby stops, stop search |
| [opentransportdata.swiss](https://opentransportdata.swiss) | SIRI-SX disruption feed |

Both APIs are free and require no authentication for basic usage.

## Tech Stack

- **Flutter 3.x / Dart** — cross-platform UI framework
- **Riverpod 2.x** — state management and dependency injection
- **Dio** — HTTP client with timeout and error handling
- **Geolocator** — GPS location (runtime permission request)
- **home_widget** — Android home screen widget bridge (SharedPreferences + RemoteViews)
- **WorkManager** — background widget refresh (15-minute periodic task)
- **SharedPreferences** — settings persistence, last stop, offline departure cache
- **flutter_localizations + intl** — ARB-based localization (DE/FR/IT/EN)

## Building

```bash
# Install dependencies
flutter pub get

# Run on connected device or emulator
flutter run

# Build release APK
flutter build apk --release

# Build Android App Bundle (for Play Store)
flutter build appbundle --release
```

Minimum Android version: **API 26 (Android 8.0)**

## App Icon

Place your 1024×1024 PNG icon at `assets/icon/icon.png`, then run:

```bash
flutter pub run flutter_launcher_icons
```

A designer-provided icon is planned for the final release (Phase 7).

## Privacy

- Location is used **only** to find nearby transport stops
- No location data is sent to any server except the public transport APIs
- The transport APIs receive only a GPS coordinate — no user identity
- No analytics, no tracking, no advertising, no accounts
- All settings are stored locally on the device

## License

MIT License — see `LICENSE` file.

*Decision rationale recorded in `docs/decisions.md` (ADR-013).*
