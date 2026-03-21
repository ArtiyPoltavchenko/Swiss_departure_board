# Phase 4: Full UI — Swiss Design, Settings, Localization, Disruptions

## Files to Change
- `lib/app.dart` — theming, localization setup, routing
- `lib/screens/board_screen.dart` — apply design, add disruption indicators
- `lib/screens/settings_screen.dart` — implement settings
- `lib/widgets/departure_tile.dart` — refined design
- `lib/widgets/countdown_chip.dart` — refined design
- `lib/widgets/disruption_badge.dart` — implement
- `lib/widgets/stop_selector.dart` — refined design
- `lib/providers/settings_provider.dart` — wire to UI
- `lib/l10n/app_de.arb`, `app_fr.arb`, `app_it.arb`, `app_en.arb`
- `pubspec.yaml` — add google_fonts if needed

## Context
Read `CLAUDE.md` before starting.
Phase 3 (minimal UI) is complete — the app opens, shows departures, allows stop switching.
Now apply real visual design inspired by Swiss public transport aesthetics, add settings screen, full 4-language localization, and disruption indicators.

## Requirements

### 1. Visual Design — Swiss Departure Board Aesthetic

The app should feel like a digital version of a real Swiss station display.

**Design direction:**
- Dark background (#1a1a2e or similar dark navy/black) with high-contrast text
- Monospaced or semi-monospaced font for departure times (use `google_fonts` package — try `Fira Mono`, `JetBrains Mono`, or `Roboto Mono`)
- Clean sans-serif for stop names and destinations (system font or `Roboto`)
- Line badges: colored rounded rectangles, category-specific colors:
  - Tram: #e20000 (SBB red)
  - Bus: #0063b6 (blue)
  - S-Bahn/Regional train: #5a6e1e (green)
  - Long-distance train: #333333 (dark)
  - Ship: #00857c (teal)
  - Cableway/funicular: #8b5e3c (brown)
  - Default: #666666
- Countdown numbers: large, bold, yellow (#ffd700) or white
- Departing now (0 min): pulsing animation or distinct color (green)
- Subtle dividers between rows
- No rounded cards — flat rows like a real board
- Status bar: stop name left-aligned, settings icon right-aligned

**Theme setup in app.dart:**
- Dark theme only (ThemeData.dark with customizations)
- Override: scaffoldBackgroundColor, appBarTheme, textTheme, colorScheme

### 2. Settings Screen

Route: push from settings icon in board_screen AppBar.

Settings:
- **Number of departures**: Dropdown, options: 5, 10, 15, 20. Default 10. Saved via Preferences.
- **Language**: Dropdown, options: Deutsch, Français, Italiano, English. Default Deutsch. Saved via Preferences. Changing language restarts localization immediately.
- **Auto-refresh interval**: Dropdown, options: 15s, 30s, 60s, 120s. Default 30s. Saved via Preferences.
- **About section** at bottom: app name, version (read from version.dart), link text "Data: transport.opendata.ch"

Design: same dark theme, simple list of settings with labels and dropdowns.

### 3. Localization (DE/FR/IT/EN)

All user-facing strings must use ARB-based localization. Minimum strings to localize:

```
- appTitle: "Departure Board" / "Abfahrtstafel" / "Tableau des départs" / "Tabella delle partenze"
- loading: "Loading..." / "Laden..." / "Chargement..." / "Caricamento..."
- noConnection: "No internet connection"
- locationDenied: "Location access denied"
- locationDisabled: "Location services disabled"
- retry: "Retry"
- openSettings: "Open Settings"
- settingsTitle: "Settings"
- departureCount: "Number of departures"
- language: "Language"
- refreshInterval: "Auto-refresh"
- seconds: "{n} seconds"
- minutes: "{n} min"
- departingNow: "Now"
- updatedAgo: "Updated {n}s ago"
- nearbyStops: "Nearby stops"
- disruption: "Disruption"
- checkSbb: "Check SBB app for details"
- about: "About"
- dataSource: "Data: transport.opendata.ch"
```

Generate all 4 ARB files with complete translations. Use native language quality (not Google Translate level — this is a Swiss app, get the transit terminology right: "Abfahrt", "départ", "partenza", "Haltestelle", "arrêt", "fermata").

### 4. Disruption Badge

`disruption_badge.dart`:
- Small ⚠️ icon (amber/yellow) shown next to departure tile if `departure.hasDisruption == true`
- On tap: show BottomSheet or Dialog with disruption summary text
- Bottom of dialog: "Check SBB app for details" (localized)

In `board_screen.dart`:
- After fetching departures, also fetch disruptions from DisruptionApi
- Match disruptions to departures by line (best effort — if no match info, skip)
- Set `hasDisruption` flag on matching departures

If DisruptionApi returns empty (including placeholder API key scenario): no badges shown, no error.

### 5. Smooth transitions
- Fade transition when departures list refreshes (AnimatedSwitcher or similar)
- Subtle slide-in for departure rows on first load (staggered animation)

## What NOT to Touch
- `lib/models/` — no model changes unless a field is missing
- `lib/services/transport_api.dart` — no API logic changes
- `lib/services/location_service.dart` — no changes
- `test/` — update tests only if provider API changed
- No widget (home screen) work — Phase 5
- No signing, no release config — Phase 7

## After Changes
1. `flutter analyze && flutter test`
2. Manual test: dark theme, all 4 languages, settings persist across restart, disruption badge shows
3. Update `docs/progress.md`
4. Record decision in `docs/decisions.md`: "Dark-only theme — matches physical departure board aesthetic, simpler maintenance"
5. Update `docs/changelog.md`
6. Update `version.dart` to `0.4.0`
7. Commit: `feat: phase 4 complete — Swiss design, settings, l10n (DE/FR/IT/EN), disruptions`
