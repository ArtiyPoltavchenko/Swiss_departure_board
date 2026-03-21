# Phase 2: Core Logic — API + Geolocation + Models

## Files to Change
- `lib/models/stop.dart`
- `lib/models/departure.dart`
- `lib/models/disruption.dart`
- `lib/services/location_service.dart`
- `lib/services/transport_api.dart`
- `lib/services/disruption_api.dart`
- `lib/services/preferences.dart`
- `lib/providers/stop_provider.dart`
- `lib/providers/departures_provider.dart`
- `lib/providers/settings_provider.dart`
- `test/models/` — unit tests for models
- `test/services/` — unit tests for API clients (mocked HTTP)

## Context
Read `CLAUDE.md` before starting.
Phase 1 (skeleton) is complete. Now implement business logic with no UI changes. Everything must be testable with mocked dependencies. After this phase, all data flows work — Phase 3 will only connect them to screens.

## Requirements

### 1. Models

**Stop** (`lib/models/stop.dart`):
```dart
class Stop {
  final String id;        // API station ID
  final String name;      // "Zürich, Bellevue"
  final double latitude;
  final double longitude;
  final int? distance;    // meters from user, nullable
}
```
- Factory `Stop.fromJson(Map<String, dynamic> json)` matching transport.opendata.ch response shape
- `toJson()` for SharedPreferences serialization

**Departure** (`lib/models/departure.dart`):
```dart
class Departure {
  final String line;          // "7", "S3", "33"
  final String destination;   // "Wollishofen"
  final DateTime scheduledTime;
  final DateTime? estimatedTime; // real-time prognosis, null if unavailable
  final String category;      // "tram", "bus", "train", "ship", "cableway", etc.
  final String? platform;     // track/platform if available
  final bool hasDisruption;   // set by merging disruption data
}
```
- Computed getter `int get minutesUntil` — minutes from now to (estimatedTime ?? scheduledTime). If ≤ 0 return 0.
- Computed getter `bool get isDeparting` — minutesUntil == 0
- Factory `Departure.fromStationboardEntry(Map<String, dynamic> json)`

**Disruption** (`lib/models/disruption.dart`):
```dart
class Disruption {
  final String summary;     // Short text
  final String? detail;     // Long text, nullable
  final String? affectedLine;
  final DateTime? validFrom;
  final DateTime? validTo;
}
```

### 2. Services

**TransportApi** (`lib/services/transport_api.dart`):
Base URL: `https://transport.opendata.ch/v1`

Methods:
```dart
/// Find nearest stops to coordinates. Returns up to [limit] stops.
Future<List<Stop>> getNearbyStops(double lat, double lng, {int limit = 5});
// GET /locations?x={lat}&y={lng}&type=station

/// Get departure board for a stop.
Future<List<Departure>> getDepartures(String stationId, {int limit = 10});
// GET /stationboard?id={stationId}&limit={limit}&fields[]=stationboard/stop&fields[]=stationboard/to&fields[]=stationboard/category
```
- Use `dio` with 10s timeout
- Handle: timeout → throw custom `ApiTimeoutException`
- Handle: no network → throw custom `NoNetworkException`
- Handle: HTTP != 200 → throw custom `ApiException(statusCode, message)`
- Handle: malformed JSON → throw custom `ApiParseException`
- All exceptions extend abstract `AppException`
- Define exceptions in `lib/services/exceptions.dart`

**DisruptionApi** (`lib/services/disruption_api.dart`):
Base URL: from opentransportdata.swiss SIRI-SX endpoint.
- API key stored as compile-time constant (Phase 7 will handle secrets properly)
- For now, create placeholder: `const String _apiKey = 'PLACEHOLDER';`
- Method: `Future<List<Disruption>> getDisruptions({String? lineRef})`
- If API key is placeholder, return empty list silently (no crash)

**LocationService** (`lib/services/location_service.dart`):
- Request permission → get current position
- Handle: permission denied → throw `LocationPermissionDeniedException`
- Handle: service disabled → throw `LocationServiceDisabledException`
- Handle: timeout → throw `LocationTimeoutException`
- Return `(double lat, double lng)` record

**Preferences** (`lib/services/preferences.dart`):
- Save/load last selected stop (as JSON string)
- Save/load departure count (int, default 10)
- Save/load locale (String, default 'de')
- All methods async, use SharedPreferences

### 3. Providers (Riverpod)

**StopProvider**: Takes location → calls `TransportApi.getNearbyStops` → exposes `AsyncValue<List<Stop>>`
**DeparturesProvider**: Takes stop ID + limit → calls `TransportApi.getDepartures` → exposes `AsyncValue<List<Departure>>`
**SettingsProvider**: Reads/writes Preferences, exposes current settings as synchronous state

Each provider must handle loading/error/data states via `AsyncValue`.

### 4. Tests

**Model tests** (`test/models/`):
- `Stop.fromJson` with real-shaped JSON → correct fields
- `Departure.fromStationboardEntry` → correct fields, `minutesUntil` logic
- Edge case: `estimatedTime` is null → fall back to `scheduledTime`

**Service tests** (`test/services/`):
- Mock dio adapter (use `dio`'s `HttpClientAdapter` or `mockito`)
- `TransportApi.getNearbyStops` — mock 200 response → returns correct `List<Stop>`
- `TransportApi.getDepartures` — mock 200 response → returns correct `List<Departure>`
- `TransportApi.getDepartures` — mock timeout → throws `ApiTimeoutException`
- `LocationService` — mock geolocator → returns coordinates

Minimum 8 tests total. All must pass.

## What NOT to Touch
- `lib/screens/` — no UI changes
- `lib/widgets/` — no UI changes
- `pubspec.yaml` — only if a missing dependency is discovered
- `android/` — no native code changes

## After Changes
1. Run `flutter analyze && flutter test`
2. All tests pass, zero analyzer errors
3. Update `docs/progress.md`
4. Record decision in `docs/decisions.md`: "Custom exception hierarchy over generic catches — explicit error handling in UI layer"
5. Update `docs/changelog.md`
6. Update `version.dart` to `0.2.0`
7. Commit: `feat: phase 2 complete — core logic, API clients, models, providers, tests`
