# Release Checklist

## Pre-Release

- [ ] `flutter analyze` passes with zero errors and warnings
- [ ] `flutter test` passes — all tests green
- [ ] `flutter build web --release` builds successfully
- [ ] `flutter build apk --release` builds successfully
- [ ] All CI checks pass on the release branch
- [ ] Code freeze: no unapproved merges to release branch
- [ ] Version bump in `pubspec.yaml`:
  - `version: x.y.z+1` (SemVer patch/minor/major)

## Firebase

- [ ] Firestore security rules deployed: `firebase deploy --only firestore:rules`
- [ ] Firestore indexes deployed: `firebase deploy --only firestore:indexes`
- [ ] Storage security rules deployed: `firebase deploy --only storage`
- [ ] Firebase project set to correct environment (staging/prod)

## Environment

- [ ] `.env` secrets updated for target environment
- [ ] `lib/config/env_config.dart` flavor set correctly
- [ ] Analytics/Crashlytics enabled for release builds
- [ ] Debug logging removed or disabled

## Testing

- [ ] Smoke test on Web (Chrome)
- [ ] Smoke test on Android (physical device or emulator)
- [ ] Auth flow: sign up, sign in, sign out, password reset
- [ ] Product CRUD: create, read, update, delete, toggle visibility
- [ ] Category CRUD: create, read, update, delete, reorder, restore
- [ ] Offer CRUD: create, read, update, delete, toggle
- [ ] Weight unit management
- [ ] RTL/Arabic layout renders correctly
- [ ] Offline mode: data available without network

## Documentation

- [ ] `CHANGELOG.md` updated with release notes
- [ ] `README.md` version references updated if needed
- [ ] API documentation updated (if applicable)

## Post-Release

- [ ] Git tag created: `git tag v1.x.y && git push origin v1.x.y`
- [ ] GitHub Release created with changelog notes
- [ ] Web build deployed to hosting (if applicable)
- [ ] APK uploaded to Play Store (if applicable)
- [ ] Release announcement made (if applicable)
