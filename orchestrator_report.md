# Orchestrator Report — Swiss Departure Board

> Last updated: 2026-03-21 (Phase 0: Planning)

## Project Summary
Native Android app (Flutter/Dart) — digital replica of Swiss public transport departure boards.
Opens to nearest stop's real-time departures via geolocation. Covers all of Switzerland.
**Stack:** Flutter 3.x, Dart, Riverpod, dio, transport.opendata.ch + opentransportdata.swiss
**Tests:** 0 passing
**Version:** 0.1.0

## Architecture
```
┌─────────────────────────────────────────────┐
│                  Flutter App                 │
│                                              │
│  ┌──────────┐  ┌────────────┐  ┌──────────┐ │
│  │ Screens  │──│ Providers  │──│ Services │ │
│  │ (UI)     │  │ (Riverpod) │  │ (API/IO) │ │
│  └──────────┘  └────────────┘  └──────────┘ │
│       │                             │        │
│  ┌──────────┐              ┌────────────────┐│
│  │ Widgets  │              │ Models (DTOs)  ││
│  │ (tiles,  │              └────────────────┘│
│  │  badges) │                     │          │
│  └──────────┘                     ▼          │
│                        ┌──────────────────┐  │
│                        │ transport.open   │  │
│                        │ data.ch (REST)   │  │
│                        ├──────────────────┤  │
│                        │ opentransport    │  │
│                        │ data.swiss (SIRI)│  │
│                        └──────────────────┘  │
├──────────────────────────────────────────────┤
│  Android Home Screen Widget (RemoteViews)    │
│  WorkManager background refresh              │
└──────────────────────────────────────────────┘
```

## File Structure
See CLAUDE.md — Project Structure section.

## Completed Phases
_None yet._

## Phase Plan
| Phase | Name | Status |
|-------|------|--------|
| 1 | Skeleton | ⏳ pending |
| 2 | Core Logic (API + Geo + Models) | ⏳ pending |
| 3 | Minimal UI (Board Screen) | ⏳ pending |
| 4 | Full UI (Design, l10n, Settings, Disruptions) | ⏳ pending |
| 5 | Android Home Screen Widget | ⏳ pending |
| 6 | Polish (Error handling, README, edge cases) | ⏳ pending |
| 7 | Publish (Signed AAB, Play Store assets) | ⏳ pending |

## Known Issues / Bugs Log
| Date | Issue | Fix |
|------|-------|-----|

## API Reference

### transport.opendata.ch
| Endpoint | Purpose |
|----------|---------|
| `GET /v1/locations?x={lat}&y={lng}&type=station` | Find nearest stops by coordinates |
| `GET /v1/stationboard?station={id}&limit={n}` | Departure board for a stop |

### opentransportdata.swiss
| Endpoint | Purpose |
|----------|---------|
| SIRI-SX situationExchange | Disruptions, cancellations, warnings |

## Running the Project
```bash
# Dev
flutter pub get
flutter run

# Tests
flutter analyze
flutter test

# Build release AAB
flutter build appbundle --release
```
