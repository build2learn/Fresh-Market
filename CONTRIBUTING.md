# Contributing to Fresh Market

Thank you for considering contributing to Fresh Market! This document outlines the guidelines for contributing.

## Code of Conduct

By participating, you agree to maintain a respectful and inclusive environment for everyone.

## How to Contribute

### Reporting Bugs

1. Check existing issues to avoid duplicates
2. Use the **Bug Report** template
3. Include:
   - Flutter version (`flutter --version`)
   - Device/OS details
   - Steps to reproduce
   - Expected vs actual behavior
   - Screenshots (if applicable)

### Suggesting Features

1. Use the **Feature Request** template
2. Describe the problem and proposed solution
3. Explain why this benefits the project

### Pull Requests

1. **Fork** the repository
2. Create a **feature branch** from `main`:
   ```bash
   git checkout -b feat/your-feature-name
   ```
3. **Follow coding standards**:
   - Run `dart format .` before committing
   - Ensure `flutter analyze` passes with zero issues
   - Write/update tests for your changes
   - Ensure `flutter test` passes
4. **Commit messages** follow [Conventional Commits](https://www.conventionalcommits.org/):
   - `feat:` — new feature
   - `fix:` — bug fix
   - `refactor:` — code change without feature/fix
   - `docs:` — documentation only
   - `test:` — test additions/changes
   - `chore:` — maintenance tasks
5. **Open a PR** against `main` using the PR template
6. Ensure CI checks pass (analyze, test, build)

## Development Setup

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/fresh-market.git
cd fresh-market

# Add upstream remote
git remote add upstream https://github.com/ORIGINAL_OWNER/fresh-market.git

# Install dependencies
flutter pub get

# Verify setup
flutter analyze && flutter test
```

## Coding Standards

- **Architecture**: Clean Architecture (data/domain/presentation layers)
- **State Management**: Riverpod providers, not StatefulWidget state
- **Naming**:
  - Files: `snake_case` (e.g., `sign_in_page.dart`)
  - Classes: `PascalCase`
  - Variables/Functions: `camelCase`
- **Imports**: Use `package:` imports. Group: Dart SDK → Flutter → packages → project
- **Tests**: Unit test all use cases and datasources. One test file per source file
- **No secrets**: Never commit `.env`, `google-services.json`, or service account files

## Architecture Rules

- Business logic only in use cases
- No Firestore calls from presentation layer
- Repository access only through use cases
- Entities must be immutable
- All strings must be localized

## Questions?

Open a [Discussion](https://github.com/YOUR_USERNAME/fresh-market/discussions) or check the existing issues.
