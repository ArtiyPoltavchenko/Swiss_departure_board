# Phase 7: Publish — Signed Build, Play Store Preparation

## Files to Change
- `android/app/build.gradle` — signing config, version from pubspec
- `android/key.properties` (new, gitignored) — keystore path and passwords
- `pubspec.yaml` — final version
- `version.dart` — release version (remove -rc if present)
- `lib/services/disruption_api.dart` — real API key (or env-based)
- Privacy Policy document (new)
- `docs/changelog.md` — release entry

## Context
Read `CLAUDE.md` before starting.
Phases 1-6 are complete. The app is functional, polished, tested.
Now prepare for Google Play release.

## Requirements

### 1. Release Signing

Create `android/key.properties` (gitignored):
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<path-to-keystore>
```

Update `android/app/build.gradle`:
```groovy
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

**Note:** Do NOT create the actual keystore. User will generate it:
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```
Document this command in README.

### 2. Version Alignment

Ensure version is consistent:
- `pubspec.yaml`: `version: 1.0.0+1`
- `version.dart`: `const String appVersion = '1.0.0';`
- build.gradle reads from pubspec.yaml automatically (Flutter default)

### 3. ProGuard Rules

Create `android/app/proguard-rules.pro`:
```
-keep class io.flutter.** { *; }
-keep class ch.swissdeparture.** { *; }
-dontwarn io.flutter.embedding.**
```
Add rules for dio, if needed (check dio documentation for ProGuard).

### 4. API Key Handling

For `disruption_api.dart`:
- Move API key to `android/app/src/main/AndroidManifest.xml` as `<meta-data>` OR
- Use `--dart-define=DISRUPTION_API_KEY=xxx` at build time
- Document the approach in README

Recommended: `--dart-define` approach:
```dart
const String _apiKey = String.fromEnvironment('DISRUPTION_API_KEY', defaultValue: '');
```
Build: `flutter build appbundle --dart-define=DISRUPTION_API_KEY=your_key`

### 5. Privacy Policy

Create `docs/privacy_policy.md`:
```markdown
# Privacy Policy — Swiss Departure Board

**Last updated: [date]**

## Data Collection
Swiss Departure Board uses your device's location to find the nearest public transport stop. Location data is sent directly to transport.opendata.ch to retrieve departure information. No location data is stored on any server controlled by the developer.

## Third-Party Services
- transport.opendata.ch — receives your coordinates to find nearby stops
- opentransportdata.swiss — receives line identifiers to check for disruptions

## Data Storage
The app stores locally on your device:
- Your last selected stop
- Your preference settings (language, departure count, refresh interval)
No personal data is transmitted to any server beyond the transport APIs listed above.

## Analytics & Tracking
None. The app contains no analytics, no advertising SDKs, no crash reporting services, and no tracking of any kind.

## Contact
[Developer email]
```

This must be hosted at a public URL for Play Store. Note in README that user needs to host it (GitHub Pages, simple HTML page, etc).

### 6. Play Store Assets Checklist

Document what the user needs to prepare (Claude Code cannot create these):
- [ ] App icon: 512x512 PNG
- [ ] Feature graphic: 1024x500 PNG
- [ ] Screenshots: minimum 2, phone resolution
- [ ] Short description (80 chars): "Real-time departure board for Swiss public transport"
- [ ] Full description (4000 chars): write draft in `docs/play_store_description.md`
- [ ] Privacy policy URL
- [ ] Content rating questionnaire answers
- [ ] Target audience: general / no children-directed content

Create `docs/play_store_description.md` with full description draft in English and German.

### 7. Build Command

Document in README:
```bash
# Generate keystore (once)
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Build signed AAB
flutter build appbundle --release --dart-define=DISRUPTION_API_KEY=your_key

# Output: build/app/outputs/bundle/release/app-release.aab
```

## What NOT to Touch
- Core app logic — no feature changes
- UI design — no visual changes
- Widget — no changes

## After Changes
1. `flutter analyze && flutter test`
2. Build release AAB successfully (unsigned is fine if no keystore yet)
3. Update `docs/progress.md` — all phases complete
4. Update `docs/changelog.md` — v1.0.0 release entry
5. Update `version.dart` to `1.0.0`
6. Commit: `chore: phase 7 complete — release config, privacy policy, Play Store prep`
7. Tag: `git tag v1.0.0`
