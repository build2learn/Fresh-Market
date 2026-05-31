# Localization Strategy

## Supported Languages
- **Arabic (ar)** - Right-to-Left (RTL) layout
- **English (en)** - Left-to-Right (LTR) layout

## Implementation Approach

### Framework: Flutter ARB + intl
Use Flutter's built-in localization system with ARB files and the `intl` package.

### File Structure
```
lib/l10n/
├── app_en.arb       # English translations
└── app_ar.arb       # Arabic translations
```

### Localization Flow
1. ARB files define key-value pairs for all user-facing strings.
2. `flutter gen-l10n` generates `AppLocalizations` class at compile time.
3. `AppLocalizations.of(context)` provides type-safe localized strings.
4. Widgets call localized strings using generated methods.

### RTL Support
- `Directionality` widget wraps the app for RTL/Arabic layouts.
- Material 3 automatically mirrors layouts for RTL.
- Custom widgets use `TextDirection` for manual alignment where needed.
- Icons and images are mirrored for RTL when appropriate.

### Key Principles
1. **No hardcoded strings** - Every user-facing string must come from ARB files.
2. **Type-safe access** - Use `AppLocalizations.of(context).productName` not string maps.
3. **Fallback locale** - English (en) is the fallback when a translation key is missing.
4. **Plural support** - Use `{count, plural, ...}` for plurals in ARB files.
5. **Gender-neutral** - Use gender-neutral phrasing in all translations.

### Language Switching
- Language preference stored in `SharedPreferences` or Firestore `settings`.
- `Provider` watches language change and triggers app rebuild.
- `MaterialApp` locale is updated, forcing rebuild with new locale.
- RTL/LTR mode switches automatically based on locale.

### ARB File Format Example
```json
{
  "@@locale": "ar",
  "appName": "السوق الطازج",
  "@appName": {
    "description": "The name of the application"
  },
  "homeTitle": "الرئيسية",
  "categories": "التصنيفات",
  "products": "المنتجات",
  "offers": "العروض",
  "addToCart": "أضف إلى السلة",
  "productCount": "{count, plural, zero{لا توجد منتجات} one{منتج واحد} two{منتجين} few{منتجات} many{منتج} other{منتج}}"
}
```

### Generating Localizations
```yaml
# pubspec.yaml
flutter:
  generate: true

# l10n.yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
preferred-supported-locales: [ar, en]
use-deferred-loading: false
synthetic-package: false
```
