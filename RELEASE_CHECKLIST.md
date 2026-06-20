# Release Checklist

## Pre-Release

- [x] `flutter analyze` passes with zero errors and warnings
- [x] `flutter test` passes — all tests green
- [x] `flutter build web --release` builds successfully
- [x] `flutter build apk --release` builds successfully
- [x] All CI checks pass on the release branch
- [x] Code freeze: no unapproved merges to release branch
- [x] Version bump in `pubspec.yaml`:
  - `version: x.y.z+1` (SemVer patch/minor/major)

## Android Release Configuration

- [x] Release keystore (`upload-keystore.jks`) generated successfully
- [x] Credentials configured in `android/key.properties`
- [x] Release signing configuration configured and mapped in `android/app/build.gradle.kts`
- [x] App launcher icons generated across all resolutions (`mipmap-mdpi`, `mipmap-hdpi`, `mipmap-xhdpi`, `mipmap-xxhdpi`, `mipmap-xxxhdpi`)
- [x] Splash screen background centered with splash logo drawable and referenced in styles
- [x] Google Services Gradle plugin registered in `settings.gradle.kts` and applied in `build.gradle.kts`

## Firebase & Notifications

- [x] Firebase `google-services.json` matches release bundle identifier
- [x] FCM token successfully stored in user document on authentication
- [x] Foreground notification listener configured in consumer app
- [x] Admin actions configured to dispatch localized notifications (Arabic & English)
- [x] Firestore security rules deployed: `firebase deploy --only firestore:rules`
- [x] Firestore indexes deployed: `firebase deploy --only firestore:indexes`
- [x] Storage security rules deployed: `firebase deploy --only storage`
- [x] Firebase project set to correct environment (staging/prod)

## Environment

- [x] `.env` secrets updated for target environment
- [x] `lib/config/env_config.dart` flavor set correctly
- [x] Analytics/Crashlytics enabled for release builds
- [x] Debug logging removed or disabled

## Testing

- [x] Smoke test on Web (Chrome)
- [x] Smoke test on Android (physical device or emulator)
- [x] Auth flow: sign up, sign in, sign out, password reset
- [x] Product CRUD: create, read, update, delete, toggle visibility
- [x] Category CRUD: create, read, update, delete, reorder, restore
- [x] Offer CRUD: create, read, update, delete, toggle
- [x] Weight unit management
- [x] RTL/Arabic layout renders correctly
- [x] Offline mode: data available without network

## Documentation

- [x] `CHANGELOG.md` updated with release notes
- [x] `README.md` version references updated if needed
- [x] API documentation updated (if applicable)

## Post-Release

- [x] Git tag created: `git tag v1.x.y && git push origin v1.x.y`
- [x] GitHub Release created with changelog notes
- [x] Web build deployed to hosting (if applicable)
- [x] APK uploaded to Play Store (if applicable)
- [x] Release announcement made (if applicable)
