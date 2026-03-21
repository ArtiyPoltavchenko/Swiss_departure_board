# Manual Testing Checklist

> Run through before each release. Check on physical device (not just emulator).

## Location & Permissions
- [ ] Fresh install: permission dialog appears
- [ ] Grant permission: nearest stop found
- [ ] Deny permission: fallback screen shown
- [ ] Deny permanently: "Open Settings" button works
- [ ] Location services off: appropriate message
- [ ] Indoor / weak GPS: falls back to last stop

## Departure Board
- [ ] Departures load and display correctly
- [ ] Line badge shows correct category color
- [ ] Countdown updates in real-time
- [ ] "Now" indicator for departing transport
- [ ] Empty board (late night): "No departures" message
- [ ] Long stop names: ellipsis, no overflow
- [ ] Long destination names: ellipsis, no overflow

## Stop Selection
- [ ] Dropdown shows nearby stops with distance
- [ ] Selecting different stop reloads departures
- [ ] Last selected stop remembered after restart

## Refresh
- [ ] Pull-to-refresh works
- [ ] Auto-refresh fires at configured interval
- [ ] "Updated Xs ago" counter is accurate
- [ ] Rapid refresh doesn't crash or duplicate data

## Settings
- [ ] Departure count change reflected on board
- [ ] Language change: all UI strings update immediately
- [ ] Refresh interval change: timer resets
- [ ] Settings persist after app restart
- [ ] About section shows correct version

## Localization
- [ ] DE: all strings present, correct Swiss transport terms
- [ ] FR: all strings present, correct
- [ ] IT: all strings present, correct
- [ ] EN: all strings present, correct
- [ ] No missing/untranslated strings in any language

## Disruptions
- [ ] ⚠️ badge appears when disruption active
- [ ] Tap badge: shows disruption detail
- [ ] No badge when no disruptions
- [ ] API key placeholder: no crash, no badge (silent)

## Widget
- [ ] Add widget to home screen
- [ ] Widget displays stop name + 3-4 departures
- [ ] Refresh button updates data
- [ ] Tap widget opens app
- [ ] Background update after ~15 min
- [ ] Widget readable on both light and dark Android themes

## Network
- [ ] No internet on launch: cached data shown with banner
- [ ] Internet lost mid-use: error message, retry button
- [ ] Internet restored: auto-recovers or retry works
- [ ] Slow connection: timeout message after 10s

## Device
- [ ] Portrait orientation
- [ ] Landscape orientation (no crash, reasonable layout)
- [ ] Screen rotation: state preserved
- [ ] App kill + reopen: last stop restored
- [ ] Back button behavior correct
- [ ] Android 8+ (API 26) minimum
