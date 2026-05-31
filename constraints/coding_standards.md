# Coding Standards

## General
- All code must be in English (identifiers, comments, documentation).
- Use Dart's `analysis_options.yaml` with strict linting rules.
- Maximum line length: 120 characters.
- Indentation: 2 spaces (no tabs).
- Files must end with a single newline.

## Dart Standards
- Use `const` constructors whenever possible.
- Prefer `final` over `var`.
- All entities must be immutable (`@freezed` or manual `==`/`hashCode`).
- Avoid `dynamic` type; use explicit types or `Object?`.
- Use `sealed class` for union types / state classes.
- All public APIs must have documentation comments.
- Use `extension` methods for reusable utility functions.

## Flutter Standards
- No `BuildContext` extension methods in core layer.
- Widgets must use `const` constructor.
- `setState` only in `StatefulWidget`; prefer Riverpod for state.
- Use `BuildContext` only for navigation, themes, and localization.

## Testing Standards
- Unit tests required for all use cases.
- Unit tests required for all repositories (with mocks).
- Widget tests for all pages and complex widgets.
- Mockito or Mocktail for mocking.
- Test file should mirror source file path under `test/`.

## File Naming
- Dart files: `snake_case.dart`
- Test files: `{name}_test.dart`
- ARB files: `app_{locale}.arb`

## Code Organization
- One class per file (except for small private classes).
- Exports should be explicit, not barrel exports for the entire package.
- Use part files sparingly.
