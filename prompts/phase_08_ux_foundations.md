# Phase 8: UX Foundations — Smart Stop Selection & Persistent Search

## Context
Read `CLAUDE.md` and `orchestrator_report.md` before starting.
All 7 original phases are complete. App builds and runs on Flutter 3.41.5.

## Problem
1. App sometimes opens on an empty stop (no departures). User sees blank screen.
2. Search view only appears when geolocation is denied. There's no way to get back to it once a stop loads.
3. Once search finds a stop, user can't easily return to search.

## Files to Change
- `lib/screens/board_screen.dart` — main changes
- `lib/services/transport_api.dart` — add peek method
- `lib/widgets/stop_selector.dart` — add search button

## Requirements

### 1. Smart Stop Selection on App Open

When the app opens and gets nearby stops from GPS:
- For each of the 5 nearest stops, do a quick departures check (limit=1) to see if any departures exist within the next 60 minutes.
- Select the nearest stop that has at least 1 upcoming departure.
- If ALL nearby stops are empty — still show the nearest one (current behavior), but display a "No upcoming departures" message instead of blank screen.
- This check must not block the UI — show a loading indicator, resolve stops sequentially or in parallel (prefer parallel with `Future.wait`).
- Cache these peek results in the existing 15s cache.

Add to `TransportApi`:
```dart
/// Quick check: does this stop have any departures in the next 60 minutes?
/// Returns true/false without fetching full board.
Future<bool> hasUpcomingDepartures(String stationId) async {
  final departures = await getDepartures(stationId, limit: 1);
  return departures.isNotEmpty && departures.first.minutesUntil <= 60;
}
```

### 2. Persistent Search Button

Add a search icon button (🔍) to the RIGHT of the stop dropdown selector.

Layout: `[ ▼ Zürich Altstetten, Bahnhof (243m)  ] [🔍]`

Tapping the search button opens the existing `_StopSearchView` overlay.
- The search view should have a back button / X to return to the main board.
- Search results list items should be tappable — selecting a stop navigates back to the board with that stop loaded.
- The search button should always be visible, regardless of geolocation state.

### 3. No Upcoming Departures State

When a selected stop has 0 departures, instead of showing an empty list, show a centered message:
- Icon: 🕐 or `Icons.schedule`
- Text: localized "No upcoming departures" / "Keine nächsten Abfahrten" / "Aucun prochain départ" / "Nessuna prossima partenza"

Add the l10n strings to all 4 ARB files.

## Acceptance Criteria
- [ ] App opens on a stop that has departures (if any nearby stop does)
- [ ] Search button visible next to stop dropdown
- [ ] Search opens overlay, selecting a stop returns to board
- [ ] Empty stop shows "No upcoming departures" message
- [ ] All 4 languages updated
- [ ] `flutter analyze` clean, `flutter build apk --debug` succeeds

## Commit
`feat: phase 8 — smart stop selection, persistent search button`

Then update `orchestrator_report.md` and `docs/progress.md`.
