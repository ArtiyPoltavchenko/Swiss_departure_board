# Phase 6: Polish — Error Handling, Edge Cases, README

## Files to Change
- `lib/screens/board_screen.dart` — error states, empty states, edge cases
- `lib/services/transport_api.dart` — retry logic, caching
- `lib/services/location_service.dart` — fallback behavior
- `README.md` — full project documentation
- `docs/testing_checklist.md` — complete manual test plan
- Various files for edge case fixes

## Context
Read `CLAUDE.md` before starting.
Phases 1-5 are complete. The app works: departure board, settings, localization, disruptions, widget.
Now harden everything for real-world use before release.

## Requirements

### 1. Error Handling & Edge Cases

**No internet on launch:**
- Show last cached departures (if any in SharedPreferences) with a banner: "Offline — showing last data from {time}"
- Retry button visible

**Location permission permanently denied:**
- Show screen explaining why location is needed
- Button: "Open App Settings" → opens Android app settings
- Alternative: text field to search for a stop by name (basic search via `GET /v1/locations?query={text}&type=station`)

**GPS slow or unavailable (indoor, tunnel):**
- After 5 seconds timeout: fall back to last known stop
- Show toast: "Using last known location"

**API returns empty stationboard:**
- Message: "No upcoming departures" (localized)
- This is valid for late night or rural stops

**API returns error:**
- Specific messages per exception type (not generic "Something went wrong")
- ApiTimeoutException: "Server not responding. Retry?"
- NoNetworkException: "No internet connection"
- ApiParseException: "Unexpected server response" (log details for debugging)

**Stop has very long name:**
- Ellipsis with max 2 lines
- Tooltip on long press showing full name

**Rapid stop switching:**
- Debounce/cancel previous API call when user switches stop quickly

### 2. Simple Response Cache

In `TransportApi`:
- Cache last stationboard response per stop ID
- Cache TTL: 15 seconds (don't re-fetch if data is fresh)
- Cache invalidated on pull-to-refresh (force refresh)
- Stored in memory (Map), not persisted

### 3. Manual Stop Search (Fallback)

If location is unavailable, show a search bar:
- Text input with debounce (300ms)
- Call `GET /v1/locations?query={text}&type=station`
- Show results in a list below
- On tap: select stop, fetch departures

This is a fallback, not the primary flow. Keep it simple.

### 4. README.md

Complete README with:
```markdown
# Swiss Departure Board 🚏

Real-time departure information for every public transport stop in Switzerland.
[1-2 sentence description]

## Features
- [bullet list of key features]

## Screenshots
[Placeholder: "Screenshots coming soon"]

## Data Sources
- transport.opendata.ch — departure data
- opentransportdata.swiss — disruption information

## Tech Stack
- Flutter 3.x / Dart
- [key packages]

## Building
[flutter pub get, flutter run, flutter build appbundle]

## Privacy
- Location is used only to find nearby stops
- No data is sent to any server except the public transport APIs
- No analytics, no tracking, no accounts

## License
[Choose: MIT or proprietary — record in decisions.md]
```

### 5. Testing Checklist

Update `docs/testing_checklist.md` with comprehensive manual test plan:
- [ ] Fresh install — location permission flow
- [ ] Permission denied — fallback behavior
- [ ] No internet — cached data display
- [ ] Switch between stops
- [ ] Pull to refresh
- [ ] Auto-refresh after 30s
- [ ] Settings: change departure count → reflected on board
- [ ] Settings: change language → UI updates
- [ ] Settings: change refresh interval → timer adjusts
- [ ] Widget: add to home screen
- [ ] Widget: refresh button
- [ ] Widget: tap to open app
- [ ] Widget: background update
- [ ] Disruption badge appears when relevant
- [ ] Late night (empty board) — "No departures" message
- [ ] Rotate device — no crash, state preserved
- [ ] Kill app and reopen — last stop remembered
- [ ] All 4 languages — complete, no missing strings
- [ ] Long stop names — ellipsis, no overflow

### 6. App Icon

Create simple app icon concept:
- Minimalist: stylized tram/bus silhouette or departure board symbol
- Swiss red (#e20000) on white, or white on dark
- Place icon files in `android/app/src/main/res/mipmap-*` directories
- Use `flutter_launcher_icons` package for generation from a single source PNG

Add to pubspec.yaml:
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.0

flutter_launcher_icons:
  android: true
  image_path: "assets/icon.png"
```

Create a simple vector icon as `assets/icon.png` (or note that designer will provide it).

## What NOT to Touch
- `lib/models/` — no structural changes
- Widget layout XML — no changes unless a display bug is found
- No new features — only polish existing ones

## After Changes
1. `flutter analyze && flutter test`
2. Run through full testing checklist
3. Update `docs/progress.md`
4. Update `docs/changelog.md`
5. Update `version.dart` to `0.6.0`
6. Commit: `feat: phase 6 complete — error handling, caching, README, testing checklist`
