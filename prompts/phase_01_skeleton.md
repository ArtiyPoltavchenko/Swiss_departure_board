# Phase 1: Project Skeleton

## Files to Create
- `pubspec.yaml`
- `lib/main.dart`
- `lib/app.dart`
- `lib/version.dart`
- `.gitignore`
- All empty model/service/provider/screen/widget/l10n directories with placeholder files
- `test/` directory structure
- `docs/progress.md`, `docs/changelog.md`, `docs/decisions.md`, `docs/testing_checklist.md`

## Context
Read `CLAUDE.md` before starting.
This is the first phase of a new Flutter project — Swiss Departure Board, a real-time public transport departure display app for Android covering all of Switzerland.

## Requirements

### 1. Create Flutter project
```bash
flutter create --org ch.swissdeparture --project-name swiss_departure_board --platforms android .
```
If the project already exists (pubspec.yaml present), skip creation and adapt existing structure.

### 2. pubspec.yaml dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  dio: ^5.4.0
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0
  geolocator: ^11.0.0
  geocoding: ^3.0.0
  shared_preferences: ^2.2.0
  home_widget: ^0.6.0
  workmanager: ^0.5.0
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  riverpod_generator: ^2.4.0
  build_runner: ^2.4.0
  mockito: ^5.4.0
  build_verify: ^3.0.0
```
Versions are approximate — use latest compatible. Do NOT pin to exact patch versions.

### 3. version.dart
```dart
/// Single source of truth for app version.
/// MAJOR.MINOR.PATCH[-rcN]
const String appVersion = '0.1.0';
```

### 4. Create directory structure
Match the tree in CLAUDE.md exactly. For each directory, create a placeholder file:
- `lib/models/` — empty `stop.dart`, `departure.dart`, `disruption.dart` with `// TODO: implement in Phase 2` comment
- `lib/services/` — empty `location_service.dart`, `transport_api.dart`, `disruption_api.dart`, `preferences.dart`
- `lib/providers/` — empty `stop_provider.dart`, `departures_provider.dart`, `settings_provider.dart`
- `lib/screens/` — empty `board_screen.dart`, `settings_screen.dart`
- `lib/widgets/` — empty `departure_tile.dart`, `stop_selector.dart`, `countdown_chip.dart`, `disruption_badge.dart`
- `lib/l10n/` — empty ARB files for DE/FR/IT/EN
- `test/models/`, `test/services/`, `test/providers/`

### 5. lib/main.dart
Minimal: runApp with ProviderScope wrapping App widget.

### 6. lib/app.dart
MaterialApp with:
- Title: 'Swiss Departure Board'
- Theme: default for now (Phase 4 will style it)
- Localization delegates registered (even if ARB files are empty)
- Home: placeholder `BoardScreen` (can be Scaffold with centered Text)

### 7. .gitignore
Standard Flutter .gitignore + additions:
```
# IDE
.idea/
.vscode/
*.iml

# Flutter
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
build/
.packages

# Android
android/.gradle/
android/local.properties
android/key.properties
android/*.keystore
android/app/release/

# Generated
*.g.dart
*.freezed.dart
.dart_tool/

# OS
.DS_Store
Thumbs.db

# Secrets
*.env
api_keys.dart
```

### 8. docs/ files
Create with headers only:
- `docs/progress.md` — "# Progress Tracker" + Phase 1 tasks as checklist
- `docs/changelog.md` — "# Changelog" + `## 0.1.0` placeholder
- `docs/decisions.md` — "# Architectural Decisions" + first decision: "Riverpod over Provider — granular state invalidation, code generation support"
- `docs/testing_checklist.md` — "# Manual Testing Checklist" + empty template

### 9. Verify
```bash
flutter pub get
flutter analyze
```
Must complete with zero errors. Warnings about unused imports in placeholder files are acceptable.

## What NOT to Touch
- No API calls yet — that is Phase 2
- No real UI — that is Phase 3
- No Android widget XML — that is Phase 5
- Do not configure signing — that is Phase 7

## After Changes
1. Run `flutter pub get && flutter analyze`
2. Update `docs/progress.md` marking Phase 1 tasks complete
3. Update `docs/changelog.md` with skeleton entry
4. Commit: `chore: project skeleton — Flutter structure, dependencies, docs`
