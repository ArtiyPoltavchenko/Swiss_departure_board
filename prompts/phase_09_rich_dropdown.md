# Phase 9: Rich Stop Dropdown — Transport Icons & Departure Preview

## Context
Read `CLAUDE.md`. Phase 8 (smart stop, search) is complete.

## Problem
The stop dropdown only shows stop name and distance. User can't tell at a glance what transport is available or how soon the next departure is.

## Files to Change
- `lib/widgets/stop_selector.dart` — major rewrite of dropdown items
- `lib/providers/stop_provider.dart` — expose next-departure data per stop
- `lib/models/departure.dart` — no changes expected
- `lib/screens/board_screen.dart` — wire enriched dropdown
- All 4 ARB files — add "notAvailable" string

## Requirements

### 1. Enriched Dropdown Items

Each stop in the dropdown shows a preview of its nearest departure:

```
┌─────────────────────────────────────────────────────┐
│ [31 🚌] Zürich Altstetten, Bahnhof (243m)      ▼  │
└─────────────────────────────────────────────────────┘
```

**Left badge block** — shows the NEXT departure's info:
- Line number in the correct category color (existing color scheme from departure_tile)
- Transport mode icon next to the number:
  - `Icons.tram` for tram
  - `Icons.directions_bus` for bus
  - `Icons.train` for train
  - `Icons.directions_boat` for ship
  - `Icons.airline_seat_recline_normal` or `Icons.cable` for cableway
- Badge has a colored BORDER (not fill) based on urgency:
  - `>= 3 min` → yellow border (`Colors.amber`)
  - `<= 2 min` → green border (`Colors.green`)
  - `Now (0 min)` → green border with a soft pulse animation (use `AnimatedContainer` or `AnimationController` with repeating fade, period ~1.5s)

**Empty stops** (no departures):
- Show `N/A` in a grey border badge instead of line number + icon

### 2. Data Flow

When nearby stops are loaded (Phase 8 already peeks departures), cache the first departure per stop.

Create a model or map: `Map<String, Departure?> nextDepartureByStop` in the stop provider or board screen state.

The dropdown reads from this map to render badges. If data isn't loaded yet, show a small `CircularProgressIndicator` in the badge area.

### 3. Animation Spec — Pulsing Green Border

For "Now" departures:
```dart
// Repeating animation: opacity 1.0 → 0.4 → 1.0, duration 1500ms
// Apply to the border color's opacity, not the whole widget
// Use AnimationController with vsync from TickerProviderStateMixin
```

Keep it subtle — this is an info indicator, not an alarm.

### 4. Dropdown Visual Polish

- Badge block is fixed-width (~70px) so all stop names align
- Stop name and distance to the right of the badge
- Selected item in the collapsed dropdown also shows the badge
- Dark theme consistent with existing app design

## Acceptance Criteria
- [ ] Each dropdown item shows line number + transport icon of next departure
- [ ] Yellow border for >= 3 min, green for <= 2 min, pulsing green for Now
- [ ] Empty stops show "N/A" grey badge
- [ ] Animation is subtle, ~1.5s period
- [ ] `flutter analyze` clean, `flutter build apk --debug` succeeds

## Commit
`feat: phase 9 — enriched stop dropdown with transport icons and urgency`

Then update `orchestrator_report.md` and `docs/progress.md`.
