# Flutter Development Skill

## Project Setup
```bash
flutter create --org com.freshmarket --project-name fresh_market --platforms android,ios,web .
```

## Dependencies (pubspec.yaml)
```yaml
dependencies:
  flutter:
    sdk: flutter
  # Firebase
  firebase_core: ^2.24.0
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
  firebase_storage: ^11.6.0
  firebase_messaging: ^14.7.0
  # State Management
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3
  # Navigation
  go_router: ^13.0.0
  # Localization
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0
  # Data
  json_annotation: ^4.8.1
  freezed_annotation: ^2.4.1
  # UI
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0
  carousel_slider: ^4.2.1
  # Utilities
  image_picker: ^1.0.7
  connectivity_plus: ^5.0.2
  shared_preferences: ^2.2.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.8
  json_serializable: ^6.7.1
  freezed: ^2.4.6
  riverpod_generator: ^2.3.9
  mockito: ^5.4.4
  mocktail: ^1.0.1
  flutter_lints: ^3.0.1
```

## Key Conventions
- Use `Riverpod` for state management with `riverpod_generator` for code generation.
- Use `GoRouter` for declarative routing with guard support.
- Use `Freezed` for immutable state classes and entities.
- Use `json_serializable` for DTO serialization.
- Use `cached_network_image` for image loading.
- Use `shimmer` for loading skeletons.
