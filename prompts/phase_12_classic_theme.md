# Phase 12: Classic Theme — LED Board Style & Theme Switcher

## Context
Read `CLAUDE.md`. Phases 8-11 are complete.

## Concept
Add a second visual theme that replicates the look of real SBB/ZVV LED departure boards — amber dot-matrix text on pure black. The existing theme becomes "Modern". User switches in Settings.

Reference: physical LAWO/Gorba LED displays at Swiss stops. Amber (#FF8C00) text, black background, monospaced dot-matrix font, minimal UI chrome.

## Files to Change / Create
- `lib/theme/` — NEW directory
  - `lib/theme/modern_theme.dart` — extract current theme
  - `lib/theme/classic_theme.dart` — LED board theme
  - `lib/theme/theme_provider.dart` — theme state
- `lib/app.dart` — wire theme provider
- `lib/screens/settings_screen.dart` — add theme picker
- `lib/services/preferences.dart` — persist theme choice
- `lib/widgets/departure_tile.dart` — adapt to theme
- `lib/widgets/countdown_chip.dart` — adapt to theme
- `lib/widgets/stop_selector.dart` — adapt to theme
- All 4 ARB files — new strings
- `pubspec.yaml` — add dot-matrix font asset if needed

## Requirements

### 1. Theme Architecture

Create `lib/theme/theme_provider.dart`:
```dart
enum AppThemeMode { modern, classic }

// StateNotifierProvider that reads/writes to Preferences
// Exposes ThemeData based on current mode
```

Both themes use dark backgrounds. The difference is in typography, colors, and visual density.

### 2. Modern Theme (existing, extracted)

Extract the current theme into `modern_theme.dart`. No visual changes — just code reorganization.

Current design:
- Dark navy/charcoal background (#1a1a2e)
- White/light grey text
- Colored line badges (tram=blue, bus=yellow, train=red, etc.)
- Material Design components
- Google Fonts (current choices)

### 3. Classic Theme (new)

**Core aesthetic — physical LED board replica:**
- Background: pure black `#000000`
- Primary text: amber `#FF8C00` (LED orange)
- Secondary text: dim amber `#CC7000`
- Muted text: dark amber `#664000`
- Green "Now" indicator: LED green `#00FF00`
- Delay text: LED red `#FF0000`

**Typography:**
- Use a monospace/dot-matrix font. Options (in order of preference):
  1. Include a custom dot-matrix font (e.g. "LED Dot-Matrix" or "Segment7" — check license, add to `assets/fonts/`)
  2. Use `google_fonts` package: `Share Tech Mono`, `VT323`, `Silkscreen`, or `DotGothic16`
  3. Fallback: `Roboto Mono` (already available)
- All text in the classic theme uses this font
- Line numbers use the same font but bolder/larger

**Line badges in classic:**
- No filled colored backgrounds
- Instead: amber text with thin amber border (like LED segment displays)
- Line number color matches the amber palette, NOT the category colors

**Countdown in classic:**
- Show minutes with apostrophe: `4'` instead of `4 min`
- "Now" shows as blinking/pulsing `>>>` in green (2s period)
- No colored chips — just text

**Departure tile in classic:**
- No cards, no elevation, no rounded corners
- Thin horizontal line separator between rows (dim amber)
- Layout:
  ```
  31  Hermetschloo                    4'
  80  Oerlikon, Bahnhof Nord         >>>
  ```
- Compact, dense, tabular — like a real display

**Header in classic:**
- Stop name in amber, no dropdown arrow styling
- "Updated Xs ago" in dim amber
- Settings icon in amber outline

**Expanded route (from Phase 11) in classic:**
- ASCII-style tree: `├── ○ StopName  14:23`
- Dots and lines in amber

### 4. Settings — Theme Picker

In settings screen, add a new section above language:
```
Theme / Darstellung / Thème / Tema
  ○ Modern
  ● Classic (LED Board)
```

Use `RadioListTile` or `SegmentedButton`. Switching theme applies immediately (no restart needed).

### 5. Persistence

Add to `preferences.dart`:
```dart
Future<String> loadTheme() async { ... }  // 'modern' or 'classic'
Future<void> saveTheme(String theme) async { ... }
```

### 6. Localization

Add to all 4 ARB files:
- `theme` — "Theme" / "Darstellung" / "Thème" / "Tema"
- `themeModern` — "Modern" / "Modern" / "Moderne" / "Moderno"
- `themeClassic` — "Classic (LED Board)" / "Klassisch (LED-Tafel)" / "Classique (tableau LED)" / "Classico (tabellone LED)"

## Design Principles
- Classic mode is NOT just a color swap. It changes typography, layout density, component shapes, and interaction patterns.
- Classic mode should feel like holding a physical departure board — dense, functional, zero decoration.
- Both themes must work with ALL features (search, favorites sidebar, expandable routes, disruption badges).
- The favorites sidebar in classic mode: black background, amber text, thin amber borders.

## Acceptance Criteria
- [ ] Two working themes: Modern (unchanged look) and Classic (LED board)
- [ ] Theme switch in settings, applies without restart
- [ ] Classic theme: amber on black, monospace font, apostrophe minutes, dense layout
- [ ] Classic theme: pulsing `>>>` for "Now" departures
- [ ] Classic theme: works correctly with favorites sidebar, search, expandable routes
- [ ] Theme persisted across restarts
- [ ] All 4 languages complete
- [ ] `flutter analyze` clean, `flutter build apk --debug` succeeds

## Commit
`feat: phase 12 — classic LED board theme with theme switcher`

Then update `orchestrator_report.md` and `docs/progress.md`.
