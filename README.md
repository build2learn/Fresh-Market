# Fresh Market 🛒

A production-grade product catalog and pricing management platform built with Flutter and Firebase. Supports bilingual (Arabic/English) operation with admin and customer roles.

## Features

- **🔐 Authentication** — Sign in, sign up, password reset with role-based access (admin/customer)
- **📦 Product Management** — Full CRUD with soft delete, toggle visibility, rich product details
- **🏷️ Category Management** — Hierarchical categories with reorder, soft delete, restore, visibility toggle
- **🎯 Offer Management** — Create, edit, toggle, and delete time-bound offers with product linking
- **⚖️ Weight Unit Management** — Configurable weight units for products
- **🌐 Bilingual** — Full Arabic/English localization with RTL support for Arabic
- **📱 Responsive Design** — Material 3 with adaptive layouts for mobile and desktop
- **🔌 Offline-First** — SQLite caching with Firestore sync for offline access
- **🎨 Modern UI** — Material Design 3 with custom theming, Cairo (Arabic) + Poppins (English) fonts

## Architecture

Clean Architecture with MVVM pattern via Riverpod:

```
lib/
├── core/          # Cross-cutting: theme, constants, errors, utils, providers
├── data/          # Data layer: DTOs, models, datasources, repositories
├── domain/        # Domain layer: entities, repository interfaces, use cases
└── presentation/  # Presentation layer: pages, providers, widgets, routing
```

- **State Management**: Riverpod + Riverpod Generator
- **Routing**: GoRouter with AuthGuard + AdminGuard
- **Data Flow**: Repository → UseCase → Provider → Widget
- **Local Cache**: SQLite via sqflite with offline-first strategy

## Technologies Used

| Layer | Technology |
|-------|-----------|
| **Framework** | Flutter 3.29.2 |
| **Language** | Dart 3.x |
| **State Management** | Riverpod + flutter_riverpod |
| **Routing** | GoRouter |
| **Backend** | Firebase (Firestore, Auth, Storage, Messaging, Crashlytics) |
| **Local Database** | SQLite via sqflite |
| **Code Generation** | build_runner, freezed, json_serializable |
| **DI** | Riverpod (built-in) |
| **Testing** | flutter_test, mocktail |
| **CI/CD** | GitHub Actions |
| **Localization** | Flutter intl + ARB files |

## Flutter Version

This project requires **Flutter 3.29.2** or later.

```bash
flutter --version
```

To verify your Flutter installation:

```bash
flutter doctor
```

## Firebase Requirements

This project uses Firebase for backend services. You need:

1. A **Firebase project** ([create one](https://console.firebase.google.com))
2. **Authentication** enabled (Email/Password)
3. **Cloud Firestore** database
4. **Firebase Storage** (for product images)
5. **Firebase Cloud Messaging** (for push notifications)
6. **Firebase Crashlytics** (for crash reporting)

### Firebase Configuration

The project supports three flavors: **development**, **staging**, and **production**.

To generate Firebase configuration files:

```bash
# Install the Firebase CLI
npm install -g firebase-tools

# Log in to Firebase
firebase login

# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your project
flutterfire configure \
  --project=your-firebase-project-id \
  --out=lib/config/firebase_options.dart \
  --platforms=android,ios,web
```

This will generate:
- `lib/config/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

**Note**: `google-services.json` is gitignored. Each developer must generate their own for local builds. CI/CD injects it via GitHub Secrets.

## Setup Instructions

### Prerequisites

- Flutter 3.29.2+
- Dart 3.x
- Firebase project
- Android Studio or VS Code (Android toolchain)
- Chrome (for web development)

### Environment Setup

```bash
# 1. Clone the repository
git clone https://github.com/YOUR_USERNAME/fresh-market.git
cd fresh-market

# 2. Install dependencies
flutter pub get

# 3. Generate Firebase configuration
#    (see Firebase Requirements section above)

# 4. Run code generation (if needed)
dart run build_runner build --delete-conflicting-outputs

# 5. Verify setup
flutter analyze
flutter test
```

### Running on Web

```bash
# Development
flutter run -d chrome

# Release build
flutter build web --release

# Serve release build
flutter run -d chrome --release
```

### Running on Android

```bash
# Create a device or start an emulator
flutter emulators --launch <emulator-id>
# OR connect a physical device with USB debugging

# Development
flutter run

# Release APK
flutter build apk

# Release App Bundle (Play Store)
flutter build appbundle
```

## Localization Support

The app supports **Arabic (ar)** and **English (en)**.

ARB files for translations:
- `lib/l10n/app_en.arb`
- `lib/l10n/app_ar.arb`

To add a new locale:
1. Create `lib/l10n/app_<locale>.arb`
2. Add the locale to `supportedLocales` in `lib/app.dart`
3. Run `flutter gen-l10n` to regenerate localizations

## Folder Structure

```
fresh-market/
├── android/                    # Android platform files
├── architecture/               # Architecture documentation
├── assets/
│   ├── fonts/                  # Cairo & Poppins font files
│   ├── images/                 # SVG/PNG assets
│   └── lottie/                 # Lottie animations
├── constraints/                # Coding standards & rules
├── decisions/                  # Architecture Decision Records (ADRs)
├── docs/                       # Project documentation
├── ios/                        # iOS platform files
├── lib/
│   ├── config/                 # App configuration & env
│   ├── core/                   # Cross-cutting concerns
│   │   ├── constants/          # App, Firestore, Route constants
│   │   ├── enums/              # Shared enumerations
│   │   ├── errors/             # Error classes & codes
│   │   ├── extensions/         # Dart/Flutter extensions
│   │   ├── infrastructure/     # Connectivity, logging
│   │   ├── providers/          # Shared providers (locale, connectivity, Firebase)
│   │   ├── services/           # Bootstrap & app-level services
│   │   ├── theme/              # Material 3 theming
│   │   └── utils/              # Validators, debouncer, Result type
│   ├── data/
│   │   ├── datasources/        # Firebase & local (SQLite) datasources
│   │   ├── dto/                # Data Transfer Objects
│   │   ├── models/             # Domain models
│   │   ├── providers/          # Repository providers
│   │   └── repositories/       # Repository implementations
│   ├── domain/
│   │   ├── entities/           # Business entities
│   │   ├── repositories/       # Abstract repository interfaces
│   │   └── usecases/           # Business logic use cases
│   ├── l10n/                   # Localization ARB files
│   ├── presentation/
│   │   ├── features/           # Feature modules (auth, products, categories, etc.)
│   │   ├── routing/            # GoRouter config + guards
│   │   └── shared/             # Shared widgets
│   ├── app.dart                # App widget
│   └── main.dart               # Entry point
├── mermaid/                    # Architecture diagrams
├── reports/                    # Audit & readiness reports
├── scripts/seed/               # Seed data scripts
├── skills/                     # AI skill definitions
├── test/                       # Unit tests
├── web/                        # Web platform files
├── .gitignore
├── analysis_options.yaml
├── build.yaml                  # build_runner config
├── l10n.yaml                   # Localization config
├── pubspec.yaml
└── README.md
```

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License — see [LICENSE](LICENSE) for details.
