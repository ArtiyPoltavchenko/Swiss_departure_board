# CLAUDE.md — Swiss Departure Board

## Project
Native Android app (Flutter/Dart) that shows real-time departure boards for the nearest public transport stop in Switzerland. Digital replica of physical station displays — open the app, see departures. No route planning, no tickets, no accounts.

## Stack
- **Frontend/App**: Flutter 3.x + Dart
- **Platform**: Android (Google Play target)
- **Primary API**: transport.opendata.ch — REST/JSON, no auth, all of Switzerland
- **Secondary API**: opentransportdata.swiss — SIRI-SX disruption feed, free API key
- **State management**: Riverpod (preferred) or Provider
- **Local storage**: SharedPreferences (settings, last stop)
- **Widget**: Android Home Screen Widget via home_widget package
- **Background**: WorkManager (via workmanager package) for widget updates
- **Geolocation**: geolocator + geocoding packages
- **HTTP**: dio
- **Localization**: flutter_localizations + intl (DE/FR/IT/EN)

## ⚠️ Runtime Environments

| Context | Constraints |
|---------|------------|
| Main app | Full Flutter, all packages available |
| Home screen widget | Native Android views only (RemoteViews). No Flutter rendering. Layout defined in XML via home_widget package. Limited to TextViews, ImageViews, LinearLayout. |
| WorkManager background | No UI context. HTTP + SharedPreferences only. |

Widget and WorkManager code MUST NOT assume Flutter widget tree is available.

## Project Structure
```
swiss_departure_board/
├── CLAUDE.md
├── orchestrator_report.md
├── pubspec.yaml
├── version.dart                  # Single source of version truth
├── .gitignore
├── README.md
│
├── prompts/                      # Orchestrator-generated prompts for Claude Code
│   ├── phase_01_skeleton.md
│   ├── phase_02_core.md
│   ├── phase_03_minimal_ui.md
│   ├── phase_04_full_ui.md
│   ├── phase_05_widget.md
│   ├── phase_06_polish.md
│   └── phase_07_publish.md
│
├── docs/
│   ├── progress.md
│   ├── changelog.md
│   ├── decisions.md
│   └── testing_checklist.md
│
├── lib/
│   ├── main.dart
│   ├── app.dart
│   │
│   ├── models/
│   │   ├── stop.dart             # Stop (id, name, coordinates)
│   │   ├── departure.dart        # Departure (line, destination, time, delay, category)
│   │   └── disruption.dart       # Disruption info from SIRI-SX
│   │
│   ├── services/
│   │   ├── location_service.dart # Geolocation wrapper
│   │   ├── transport_api.dart    # transport.opendata.ch client
│   │   ├── disruption_api.dart   # opentransportdata.swiss client
│   │   └── preferences.dart      # SharedPreferences wrapper
│   │
│   ├── providers/
│   │   ├── stop_provider.dart
│   │   ├── departures_provider.dart
│   │   └── settings_provider.dart
│   │
│   ├── screens/
│   │   ├── board_screen.dart     # Main departure board
│   │   └── settings_screen.dart
│   │
│   ├── widgets/
│   │   ├── departure_tile.dart   # Single departure row
│   │   ├── stop_selector.dart    # Dropdown for nearby stops
│   │   ├── countdown_chip.dart   # Minutes countdown or "now" icon
│   │   └── disruption_badge.dart # ⚠️ indicator
│   │
│   └── l10n/
│       ├── app_de.arb
│       ├── app_fr.arb
│       ├── app_it.arb
│       └── app_en.arb
│
├── android/
│   └── app/src/main/res/layout/
│       └── widget_layout.xml     # Home screen widget layout
│
└── test/
    ├── models/
    ├── services/
    └── providers/
```

## Development Rules

### Code
- Dart: follow `dart analyze` with zero warnings, `dart format`
- All comments, variable names, UI strings — English
- Localized user-facing strings via ARB files, never hardcode
- Null safety: strict, no `!` operator unless justified in comment
- API calls: always handle timeout, no-network, malformed response
- Platform-dependent imports: wrap in try/catch or conditional import

### Git
- Commits: `type: description` (feat/fix/refactor/docs/test/chore)
- One feature = one commit
- Update `version.dart` when behavior changes

### Versioning
- PATCH++ for bugfix
- MINOR++ (PATCH=0) for new feature
- MAJOR++ (MINOR=0, PATCH=0) for breaking change
- Append `-rc1` for release candidates

### Testing
- `flutter test` for unit tests
- Mock HTTP responses — never call real API in tests
- Mock geolocator — never request real location in tests
- Run `flutter analyze && flutter test` before every commit

## Workflow

1. Read `docs/progress.md` before starting
2. Make a plan → show user for approval
3. Execute one task at a time
4. After each task: update `docs/progress.md`, commit
5. Architectural decision → record in `docs/decisions.md`

## Project Memory
- `orchestrator_report.md` — full state for new chat handoff
- `docs/progress.md` — task tracker
- `docs/decisions.md` — why X not Y
- `docs/changelog.md` — what changed

## Context Control
If session runs long or you notice context degradation —
explicitly tell user:
"⚠️ Recommend transferring context to a new chat.
I will update orchestrator_report.md and commit the state."
Then: update orchestrator_report.md, ensure everything is committed.

## Reminders
- Update docs/ after every task
- Ask confirmation before next phase
- Never hardcode stop names, line numbers, or Swiss-specific strings
- API responses may return empty arrays — always handle gracefully
- Widget layout must work with both light and dark Android themes
- All 4 languages (DE/FR/IT/EN) must have complete translations before release
