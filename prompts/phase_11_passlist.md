# Phase 11: Route Stops — Expandable Departure Tiles with PassList

## Context
Read `CLAUDE.md`. Phases 8-10 are complete.

## Problem
Users want to see the full route of a departing vehicle — which stops it already passed and which are upcoming. Like the "i" button on physical Swiss departure boards.

## API Investigation Required

The transport.opendata.ch API returns `passList` data for stationboard entries. Before implementing, test the API response:

```
GET https://transport.opendata.ch/v1/stationboard?id=8503000&limit=3
```

Check if `passList` is already in the response. If not, try:
```
GET https://transport.opendata.ch/v1/stationboard?id=8503000&limit=3&fields[]=stationboard/passList
```

The `passList` should be an array of stop checkpoints, each with:
- `station.name` — stop name
- `arrival` / `departure` — scheduled times
- `prognosis.arrival` / `prognosis.departure` — real-time prognosis

**IMPORTANT:** If the API does NOT return passList in stationboard, an alternative approach is:
1. Use `/connections?from={currentStop}&to={destination}` endpoint to get the route
2. Match by departure time + line number to get the correct connection
3. Extract `sections[].journey.passList` from the connection

Test both approaches and use whichever returns data reliably. Document the decision in `docs/decisions.md` as ADR-018.

## Files to Change / Create
- `lib/services/transport_api.dart` — modify stationboard call or add route fetcher
- `lib/models/departure.dart` — add `passList` field
- `lib/models/route_stop.dart` — NEW: model for a stop in the route
- `lib/widgets/departure_tile.dart` — convert to `ExpansionTile`
- All 4 ARB files — new strings

## Requirements

### 1. RouteStop Model

Create `lib/models/route_stop.dart`:
```dart
class RouteStop {
  final String name;
  final DateTime? arrival;
  final DateTime? departure;
  final DateTime? estimatedArrival;
  final DateTime? estimatedDeparture;
  final bool isPassed;  // true if this stop is before the current station

  const RouteStop({ ... });
  factory RouteStop.fromJson(Map<String, dynamic> json, {required String currentStationId}) { ... }
}
```

### 2. Departure Model Extension

Add to `Departure`:
```dart
final List<RouteStop>? passList;  // null = not loaded, empty = no data
```

Update `fromStationboardEntry` to parse `passList` if present.
Add `copyWith` or extend `withDisruption` pattern.

### 3. Expandable Departure Tile

Convert `DepartureTile` from a flat `ListTile` to an `ExpansionTile`:

**Collapsed state** (current look — no visual change):
```
[31] Zürich, Hermetschloo  Pl. A     3 min
```

**Expanded state** (tap to expand):
```
[31] Zürich, Hermetschloo  Pl. A     3 min
  ├─ ● Zürich, Farbhof          14:23   ← passed (grey, dimmed)
  ├─ ● Zürich, Letzigrund       14:25   ← passed (grey, dimmed)
  ├─ ◉ Zürich Altstetten ★      14:27   ← CURRENT STOP (highlighted, white bold)
  ├─ ○ Zürich, Hermetschloo     14:29   ← upcoming (normal)
  ├─ ○ Zürich, Frankental       14:31   ← upcoming
  └─ ○ Zürich, Glaubtenstr.     14:33   ← final stop
```

**Visual spec:**
- Passed stops: grey text, filled grey dot `●`
- Current stop: white bold text, large filled dot `◉`, highlighted with subtle background
- Upcoming stops: normal text color, empty dot `○`
- Vertical connecting line between dots (left side, thin grey line)
- Times shown in HH:mm format on the right
- If prognosis differs from scheduled → show delay in amber (like main board)
- Expansion arrow on the right side of the tile (standard `ExpansionTile` trailing)

### 4. Lazy Loading

PassList data may be large. Don't fetch it for all departures upfront.

**Strategy:**
- On first expand of a tile → fetch passList (show small spinner while loading)
- Cache per departure (line + scheduled time as key) for session lifetime
- If fetch fails → show "Route information unavailable" inside expanded tile
- Collapsed → no API call

### 5. Localization

Add to all 4 ARB files:
- `routeInfo` — "Route" / "Route" / "Itinéraire" / "Percorso"
- `routeUnavailable` — "Route information unavailable" / "Routeninformation nicht verfügbar" / "Information d'itinéraire indisponible" / "Informazioni percorso non disponibili"
- `currentStop` — "Current stop" / "Aktuelle Haltestelle" / "Arrêt actuel" / "Fermata attuale"
- `passedStops` — "Passed" / "Vorbei" / "Passé" / "Passato"

## Acceptance Criteria
- [ ] Tapping a departure tile expands to show route stops
- [ ] Passed stops are greyed out, current stop is highlighted
- [ ] Route data loaded lazily on first expand
- [ ] Loading spinner shown during fetch
- [ ] Graceful fallback if API doesn't provide passList
- [ ] ADR-018 documented with API approach chosen
- [ ] All 4 languages complete
- [ ] `flutter analyze` clean, `flutter build apk --debug` succeeds

## Commit
`feat: phase 11 — expandable departure tiles with route stops`

Then update `orchestrator_report.md` and `docs/progress.md`.
