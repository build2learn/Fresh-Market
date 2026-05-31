# Architecture Rules

## Mandatory Rules

### Rule 1: No Business Logic in UI
- UI widgets must not contain business logic.
- Business logic belongs in Use Cases (domain layer).
- Presentation layer only calls use cases and maps results to UI state.

### Rule 2: No Direct Firestore Calls from Presentation
- Presentation layer must never import Firestore.
- All Firebase interactions happen in the data layer only.
- Repository interfaces in domain layer are pure Dart.

### Rule 3: Repository Access Only Through Use Cases
- Presentation providers must not access repositories directly.
- All data operations go through a use case.
- Exception: Stream subscriptions in the data layer may bypass use cases for real-time updates, but must still go through repository abstraction.

### Rule 4: All Strings Localized
- Every user-facing string must come from `AppLocalizations`.
- No hardcoded Arabic or English text in widget files.
- Error messages must be localized.

### Rule 5: All Entities Immutable
- Domain entities must be immutable classes.
- Use `@freezed` or implement `==` and `hashCode` manually.
- No setters on entity fields.

### Rule 6: Feature-First Organization
- Code is organized by feature, not by type.
- Each feature has its own `pages/`, `providers/`, `widgets/` directories.
- Shared widgets go in `presentation/common/widgets/`.

### Rule 7: Testable Architecture
- All use cases must accept repositories via constructor injection.
- All repositories must accept data sources via constructor injection.
- No static methods or global singletons for data access.

### Rule 8: Responsive Layouts
- All pages must support mobile and web form factors.
- Use `LayoutBuilder` or `MediaQuery` for breakpoints.
- Admin dashboard must adapt from side-nav (web) to bottom-nav (mobile).

## Enforced Patterns

### Dependency Injection
```
Provider (Riverpod)
  └─► creates UseCase
        └─► accepts Repository (interface)
              └─► RepositoryImpl
                    └─► accepts DataSources
```

### Error Handling
- Use Cases return `Either<Failure, T>` or throw typed exceptions.
- Presentation layer catches exceptions and maps to user-friendly messages.
- All error messages must be localized.

### State Management Flow
```
Widget ──► Provider ──► UseCase ──► Repository
  ▲                                  │
  │                                  ▼
  └──────────────── Data Sources (Firebase/Local)
```
