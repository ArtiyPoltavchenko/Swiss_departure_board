# Phase 10: Favorites — Star Button, Sidebar, Persistence

## Context
Read `CLAUDE.md`. Phases 8-9 are complete.

## Problem
Users who commute between a few stops daily have to wait for GPS every time. No way to quickly jump to a known stop.

## Files to Change / Create
- `lib/services/preferences.dart` — add favorites CRUD
- `lib/providers/favorites_provider.dart` — NEW: StateNotifier for favorites list
- `lib/widgets/favorites_sidebar.dart` — NEW: Drawer with favorites list
- `lib/screens/board_screen.dart` — add star button, burger menu, Scaffold drawer
- All 4 ARB files — new strings

## Requirements

### 1. Data Model & Persistence

Store favorites as a JSON list in SharedPreferences.

In `preferences.dart` add:
```dart
// Key: 'favorite_stops'
// Value: JSON array of Stop.toJson() objects
// Max: 20 favorites (soft limit, warn user)

Future<List<Stop>> loadFavorites() async { ... }
Future<void> saveFavorites(List<Stop> stops) async { ... }
```

### 2. Favorites Provider

Create `lib/providers/favorites_provider.dart`:
```dart
// StateNotifierProvider<FavoritesNotifier, List<Stop>>
// Methods: add(Stop), remove(String stopId), isFavorite(String stopId), reorder(int old, int new)
// Loads from preferences on init, saves on every mutation
```

### 3. Star Button — Add/Remove Favorite

Below the stop dropdown, to the right, add a star button:
```
[ ▼ Zürich Altstetten, Bahnhof (243m) ] [🔍]
                                    [☆ Add to favorites]
```

- When current stop is NOT in favorites: outlined star `Icons.star_border`, text "Add to favorites"
- When current stop IS in favorites: filled yellow star `Icons.star`, `Colors.amber`, text "In favorites"
- Tapping toggles. Use a brief scale animation on toggle.
- Text is localized in all 4 languages.

### 4. Burger Menu → Favorites Sidebar

Replace the settings gear icon in the top-right with a layout:
- **Top-LEFT of header**: hamburger icon `Icons.menu` → opens Drawer
- **Top-RIGHT of header**: settings gear icon (keep existing)

The Drawer (sidebar) contains:
```
┌──────────────────────────┐
│  ★ Favorites             │  ← header
│─────────────────────────│
│  ★ Zürich HB             │  ← tap to switch
│  ★ Bern, Bahnhof         │
│  ★ Basel SBB             │
│─────────────────────────│
│  No favorites yet.       │  ← empty state
│  Star a stop to save it. │
│─────────────────────────│
│                          │
│  [Manage]                │  ← opens reorder/delete mode
└──────────────────────────┘
```

**Sidebar behavior:**
- Tapping a favorite stop: closes sidebar, switches board to that stop (same as selecting from dropdown)
- Each favorite shows: stop name only (no distance — it's not relevant for saved stops)
- "Manage" mode: `ReorderableListView` + swipe-to-delete (or trailing delete icon)
- Drawer uses dark theme matching the app
- Maximum 20 favorites; if at limit, show a toast "Maximum 20 favorites reached"

### 5. Localization

Add to all 4 ARB files:
- `favorites` — "Favorites" / "Favoriten" / "Favoris" / "Preferiti"
- `addToFavorites` — "Add to favorites" / "Zu Favoriten" / "Ajouter aux favoris" / "Aggiungi ai preferiti"
- `inFavorites` — "In favorites" / "In Favoriten" / "Dans les favoris" / "Nei preferiti"
- `noFavorites` — "No favorites yet" / "Noch keine Favoriten" / "Pas encore de favoris" / "Nessun preferito"
- `noFavoritesHint` — "Star a stop to save it here." / etc.
- `manage` — "Manage" / "Verwalten" / "Gérer" / "Gestisci"
- `maxFavorites` — "Maximum 20 favorites reached" / etc.
- `removedFromFavorites` — "Removed from favorites" / etc.

### 6. Widget Update

If the home screen widget exists and the user has favorites — the widget should use the first favorite as fallback when GPS is unavailable (instead of last-used stop). This is a minor change in `widget_service.dart`.

## Acceptance Criteria
- [ ] Star button toggles favorite on/off with animation
- [ ] Burger menu opens sidebar with favorites list
- [ ] Tapping favorite switches to that stop
- [ ] Manage mode allows reorder and delete
- [ ] Favorites persist across app restarts
- [ ] Empty state shown when no favorites
- [ ] All 4 languages complete
- [ ] `flutter analyze` clean, `flutter build apk --debug` succeeds

## Commit
`feat: phase 10 — favorites system with sidebar and persistence`

Then update `orchestrator_report.md` and `docs/progress.md`.
