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
