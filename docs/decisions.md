# Architectural Decisions

## ADR-001: Flutter + Dart (not Kotlin native)
**Date:** 2026-03-21
**Decision:** Use Flutter/Dart instead of native Kotlin.
**Rationale:** Faster development, single codebase. App is UI-heavy with simple platform needs. Home screen widget is the only native-dependent feature, handled by home_widget package. Future iOS port becomes trivial.
**Trade-off:** Widget limited to RemoteViews (no Flutter rendering). Accepted.

## ADR-002: Riverpod over Provider
**Date:** 2026-03-21
**Decision:** Riverpod for state management.
**Rationale:** Granular invalidation, code generation support, better testability, no BuildContext dependency for providers. Provider is simpler but scales worse.

## ADR-003: transport.opendata.ch as primary (not SBB API)
**Date:** 2026-03-21
**Decision:** Use transport.opendata.ch REST API.
**Rationale:** No auth required, covers all of Switzerland (all operators), JSON responses, well-documented. SBB API requires registration and is more complex. opentransportdata.swiss used only for disruption data.

## ADR-004: No backend server
**Date:** 2026-03-21
**Decision:** All API calls directly from device.
**Rationale:** Eliminates hosting costs, maintenance, and privacy concerns. Public APIs are free and reliable. No need for push notifications or user accounts.

## ADR-005: Dark theme only
**Date:** 2026-03-21
**Decision:** Single dark theme matching physical station displays.
**Rationale:** Real Swiss departure boards are dark background with light text. Maintaining one theme halves design and testing work. OLED-friendly. If users request light theme, add in future version.

## ADR-006: Custom exception hierarchy over generic catches
**Date:** 2026-03-21
**Decision:** All service errors are wrapped in typed `AppException` subclasses before reaching providers/UI.
**Rationale:** Explicit error types let the UI layer display context-specific messages (timeout ≠ no network ≠ permission denied). Generic `catch (e)` at UI level would lose that distinction. The hierarchy is shallow — one abstract base class and 7 leaf types — keeping it easy to extend.

## ADR-007: Injectable position getter in LocationService
**Date:** 2026-03-21
**Decision:** `LocationService` accepts an optional `PositionGetter` function in its constructor.
**Rationale:** Real geolocator APIs require device hardware; tests must not touch real GPS. Injecting the getter function avoids mockito code generation while keeping production code unchanged (getter is null by default).

## ADR-008: Dio HttpClientAdapter for API tests (no mockito code generation)
**Date:** 2026-03-21
**Decision:** API tests use a custom `_MockAdapter` implementing `HttpClientAdapter`.
**Rationale:** mockito 5.x requires `build_runner` to generate mock classes. Since the generated files are excluded from git and the CI environment has no Flutter toolchain, a hand-written adapter is simpler, requires no code generation, and tests the exact same code paths.

## ADR-009: Dark-only theme — matches physical departure board aesthetic
**Date:** 2026-03-21
**Decision:** Single dark theme only (#1a1a2e background).
**Rationale:** Real Swiss SBB departure boards use dark backgrounds with high-contrast text. A single theme halves design and testing work, improves OLED battery life, and gives a consistent brand feel. A light theme option can be added in a future version if users request it.

## ADR-010: ConsumerWidget for App root — live locale switching
**Date:** 2026-03-21
**Decision:** App widget extends ConsumerWidget and watches settingsProvider for the locale.
**Rationale:** Flutter's MaterialApp.locale is respected at runtime. By watching the Riverpod settings state in the App root, changing the language in SettingsScreen causes MaterialApp to rebuild with the new locale immediately — no app restart required.

## ADR-011: Widget data via SharedPreferences bridge (home_widget pattern)
**Date:** 2026-03-21
**Decision:** Widget data is passed from Dart to the native AppWidgetProvider via SharedPreferences, using the home_widget package. No custom platform channel is needed.
**Rationale:** home_widget is the standard community solution for this. It stores data under "HomeWidgetPlugin" SharedPreferences, provides HomeWidgetLaunchIntent and HomeWidgetBackgroundIntent helpers for Kotlin, and handles the Dart↔native bridge for background callbacks. A custom platform channel would duplicate this work.

## ADR-012: WidgetService as static class — no Riverpod in background
**Date:** 2026-03-21
**Decision:** WidgetService uses direct instantiation (TransportApi(), SharedPreferences.getInstance()) rather than Riverpod providers.
**Rationale:** WorkManager and HomeWidget callbacks run in an isolate without a Flutter widget tree. Riverpod providers require a ProviderScope which cannot exist outside the app. Static methods with direct instantiation are the correct pattern for background tasks.

## ADR-013: MIT License
**Date:** 2026-03-21
**Decision:** The app is released under the MIT License.
**Rationale:** Open source with minimal restrictions. The app adds value through UX, not secret data. Using public APIs with no proprietary data. MIT is compatible with all dependencies.

## ADR-014: In-memory stationboard cache (15s TTL)
**Date:** 2026-03-21
**Decision:** TransportApi caches getDepartures results in a Map for 15 seconds. Pull-to-refresh passes forceRefresh:true to bypass it.
**Rationale:** Users frequently rotate screen, switch settings, or open/close the app in quick succession. 15s prevents redundant API calls without showing perceptibly stale data (the board auto-refreshes every 30s anyway).

## ADR-015: Disk departure cache for offline fallback
**Date:** 2026-03-21
**Decision:** After every successful getDepartures call, a minimal JSON representation is saved to SharedPreferences. On NoNetworkException, the cached data is loaded and shown with an offline banner.
**Rationale:** The most common failure mode (brief loss of mobile data) should not blank the screen. Departure times will be stale but the stop name and line numbers are still useful for orientation.

## ADR-016: API key via --dart-define, not committed to source
**Date:** 2026-03-21
**Decision:** The opentransportdata.swiss API key is injected at build time via `--dart-define=DISRUPTION_API_KEY=xxx`. The app uses `String.fromEnvironment('DISRUPTION_API_KEY', defaultValue: '')`. If the key is absent, disruption features degrade silently.
**Rationale:** Prevents accidental key exposure in git history. Allows CI/CD to inject the key from a secret vault. Keeps local development working without a key.

## ADR-017: key.properties template committed; keystore NOT committed
**Date:** 2026-03-21
**Decision:** A template `android/key.properties` file (with placeholder values and instructions) is committed. The actual populated file is gitignored. The keystore file is never committed.
**Rationale:** Template reduces friction for new developers setting up signing. The sensitive credential file stays off git. Follows standard Flutter signing documentation pattern.
