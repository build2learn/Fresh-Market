# Localization Skill

## Setup (l10n.yaml)
```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
preferred-supported-locales: [ar, en]
use-deferred-loading: false
synthetic-package: false
```

## ARB File Format (app_ar.arb)
```json
{
  "@@locale": "ar",
  "appName": "السوق الطازج",
  "homeTitle": "الرئيسية",
  "categories": "التصنيفات",
  "offers": "العروض",
  "products": "المنتجات",
  "addToCart": "أضف إلى السلة"
}
```

## ARB File Format (app_en.arb)
```json
{
  "@@locale": "en",
  "appName": "Fresh Market",
  "homeTitle": "Home",
  "categories": "Categories",
  "offers": "Offers",
  "products": "Products",
  "addToCart": "Add to Cart"
}
```

## Usage in Widgets
```dart
// In any widget
final localizedStrings = AppLocalizations.of(context);

// String access
Text(localizedStrings.homeTitle);

// Plural
Text(localizedStrings.productCount(5)); // "5 products"

// With parameters
Text(localizedStrings.welcomeUser(userName));
```

## Generating Localizations
```bash
flutter gen-l10n
```

## Language Switching
```dart
// Set locale
void setLocale(Locale locale) {
  ref.read(localeProvider.notifier).state = locale;
}

// MaterialApp setup
MaterialApp(
  locale: ref.watch(localeProvider),
  supportedLocales: const [Locale('ar'), Locale('en')],
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  localeResolutionCallback: (locale, supportedLocales) {
    // Determine best match
  },
);
```

## RTL Support
- Material 3 automatically handles RTL layout when locale is Arabic.
- Use `Directionality.maybeOf(context)` to check RTL.
- Mirror icons for RTL: `Transform.flip(flipX: true, child: Icon(...))`.
- Bi-directional text handling with `UnicodeDirectionality` characters if needed.
