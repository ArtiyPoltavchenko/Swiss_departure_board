# Phase 3: Minimal UI — Departure Board Screen

## Files to Change
- `lib/screens/board_screen.dart`
- `lib/widgets/departure_tile.dart`
- `lib/widgets/stop_selector.dart`
- `lib/widgets/countdown_chip.dart`
- `lib/app.dart` (wire up real screen)
- `lib/main.dart` (ensure ProviderScope is correct)

## Context
Read `CLAUDE.md` before starting.
Phase 2 (core logic) is complete — models, API clients, providers all work and are tested.
Now build the minimal working UI: open the app → see departure board. No styling, no settings screen, no disruptions display, no localization — just functional.

## Requirements

### 1. board_screen.dart — Main Screen

On init:
1. Request location via LocationService
2. Call getNearbyStops with coordinates
3. Select first (nearest) stop
4. Call getDepartures for that stop
5. Display departure list

State handling:
- **Loading**: centered CircularProgressIndicator
- **Error (location denied)**: centered message + button to open app settings
- **Error (location disabled)**: centered message + button to open location settings
- **Error (API)**: centered message + retry button
- **Data**: departure list

Auto-refresh: set up a Timer.periodic (default 30 seconds) that re-fetches departures. Timer must be cancelled in dispose.

Pull-to-refresh: wrap list in RefreshIndicator.

Display at top of screen:
- Stop name (large, bold)
- Small text: "Updated X seconds ago"

### 2. departure_tile.dart — Single Departure Row

Layout (single ListTile-like row):
```
[Line badge]  [Destination]                    [Countdown]
   7          Wollishofen                         4 min
```

- **Line badge**: Container with line number/name, colored background (use a simple hash of line name for color, or category-based: tram=red, bus=blue, train=black, ship=teal, default=grey). Rounded corners, white text.
- **Destination**: Text, ellipsis overflow, expanded
- **Countdown**: from `countdown_chip.dart`

### 3. countdown_chip.dart

- If `minutesUntil > 0`: show `"{n} min"` text
- If `minutesUntil == 0` (isDeparting): show a departure icon (e.g., `Icons.directions_walk` or a pulsing indicator) — this means the vehicle is at the stop now
- Style: bold, right-aligned

### 4. stop_selector.dart

- Dropdown (DropdownButton or PopupMenuButton) showing nearby stops
- Each item: stop name + distance in meters (e.g., "Bellevue (120 m)")
- On selection: update the active stop, re-fetch departures
- Only shown if more than 1 stop is available

### 5. Wire up in app.dart
- Set `home: BoardScreen()` in MaterialApp
- Ensure ProviderScope wraps everything in main.dart

### 6. Verify manually
The app should:
- Open → request location permission
- Show loading spinner
- Display nearest stop name
- Display departure list with line, destination, countdown
- Allow switching stops via dropdown
- Pull down to refresh
- Auto-refresh every 30s

## What NOT to Touch
- `lib/models/` — no model changes
- `lib/services/` — no service changes (unless a bug is found, then fix + note)
- `lib/l10n/` — no localization yet
- `test/` — add widget tests only if time permits, not mandatory this phase
- No settings screen yet
- No disruption badges yet

## After Changes
1. Run `flutter analyze && flutter test` — existing tests still pass
2. Manual test on emulator/device: confirm the flow works end to end
3. Update `docs/progress.md`
4. Update `docs/changelog.md`
5. Update `version.dart` to `0.3.0`
6. Commit: `feat: phase 3 complete — minimal departure board UI`
