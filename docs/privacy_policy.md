# Privacy Policy — Swiss Departure Board

**Last updated: 2026-03-21**

## Summary

Swiss Departure Board is a simple utility app that shows public transport
departure times. It uses your location to find the nearest stop. It does not
collect, store, or share any personal data.

---

## 1. Data We Collect

### Location Data
When you open the app, it requests access to your device's location (GPS).
Your coordinates are used **only** to find the nearest public transport stop.

- Location data is **not stored** on any server controlled by the developer.
- Location data is **not sold** or shared with third parties.
- You can deny location permission and manually search for a stop by name instead.

### No Other Personal Data
We do not collect names, email addresses, phone numbers, device identifiers,
advertising IDs, or any other personally identifiable information.

---

## 2. Third-Party Services

The app communicates with two public APIs. No user account or identity is involved.

| Service | Data Sent | Purpose |
|---------|-----------|---------|
| [transport.opendata.ch](https://transport.opendata.ch) | GPS coordinates (latitude/longitude) | Find nearby stops; retrieve departure times |
| [opentransportdata.swiss](https://opentransportdata.swiss) | Line identifiers | Retrieve active service disruptions |

These services are operated by Swiss public transport authorities. Consult their
respective privacy policies for details on how they handle request data.

---

## 3. Local Storage

The app stores the following data **locally on your device only**:

- Your last selected transport stop
- App settings (language preference, departure count, refresh interval)
- A cache of recent departure times (used when offline)

This data never leaves your device except as part of API requests described above.

---

## 4. Home Screen Widget

If you add the home screen widget, the app runs a background task every
~15 minutes to refresh departure data. This background task makes the same
API calls described above (coordinates → stop → departures). No additional
data is transmitted.

---

## 5. Analytics & Tracking

**None.** The app contains:
- No analytics SDK (no Firebase, no Mixpanel, no Amplitude)
- No advertising SDK
- No crash reporting service
- No A/B testing or feature flags tied to user identity
- No tracking pixels or beacons

---

## 6. Children

The app does not knowingly collect data from children under 13.
The app contains no age-restricted content.

---

## 7. Changes to This Policy

If this policy changes materially, the updated version will be posted at the
same URL with a new "Last updated" date.

---

## 8. Contact

For questions about this privacy policy:

**Developer:** [Your Name / Organisation]
**Email:** [your-email@example.com]

---

*This privacy policy must be hosted at a publicly accessible URL before
submitting to Google Play. Recommended: GitHub Pages, Netlify, or a simple
hosted HTML page.*
