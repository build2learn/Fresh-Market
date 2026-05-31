# Firestore Seed Data

## Files

- `seed_data.dart` — Dart class with all seed data + `FirestoreSeeder` class. Import in your Flutter app to seed during development.
- `seed_data.json` — Pure JSON version. Use for manual import via Firebase Console or the Node.js script.
- `import.mjs` — Node.js script using `firebase-admin` for automated import from JSON.

## Method 1: Flutter in-app seeding (development only)

Call `FirestoreSeeder` from your app's initialization when running in debug mode:

```dart
// In main.dart or app.dart
import 'package:fresh_market/scripts/seed_data.dart';

if (bool.fromEnvironment('SEED_DATA', defaultValue: false)) {
  final seeder = FirestoreSeeder(firestore: FirebaseFirestore.instance);
  await seeder.seedAll();
}
```

Run: `flutter run --dart-define=SEED_DATA=true`

## Method 2: Node.js import script

1. Install dependencies:
   ```bash
   cd scripts/seed
   npm install firebase-admin
   ```

2. Download your Firebase service account key:
   - Firebase Console → Project Settings → Service Accounts
   - "Generate New Private Key" → save as `serviceAccount.json`

3. Run the import:
   ```bash
   node scripts/seed/import.mjs --key=path/to/serviceAccount.json
   ```

   Options:
   - `--overwrite` — Update existing documents (default: skip duplicates)
   - `--dry-run` — Preview changes without writing

## Method 3: Firebase Console (manual)

1. Open Firebase Console → Firestore Database
2. Select your project
3. Import each collection:
   - Copy the relevant JSON array from `seed_data.json`
   - Create the collection and add documents manually
   - Or use the "Import" button with a `gs://` export

## Import order

Categories and Weight Units must be imported before Products (products reference category/weight unit IDs). Offers can be imported anytime.
