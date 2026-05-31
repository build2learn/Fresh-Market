/**
 * Firestore Seed Data Importer
 *
 * Usage:
 *   1. Install dependencies: npm install firebase-admin
 *   2. Download your service account JSON from Firebase Console
 *      (Project Settings > Service Accounts > Generate New Private Key)
 *   3. Run: node scripts/seed/import.mjs --key=path/to/serviceAccount.json
 *
 * Options:
 *   --key, -k   Path to Firebase service account key (required)
 *   --overwrite Overwrite existing documents (default: false)
 *   --dry-run   Print what would be done without writing (default: false)
 */

import admin from 'firebase-admin';
import { readFileSync, existsSync } from 'fs';
import { resolve, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));

function parseArgs() {
  const args = process.argv.slice(2);
  const flags = { key: null, overwrite: false, dryRun: false };

  for (const arg of args) {
    if (arg.startsWith('--key=') || arg.startsWith('-k=')) {
      flags.key = arg.split('=')[1];
    } else if (arg === '--overwrite') {
      flags.overwrite = true;
    } else if (arg === '--dry-run') {
      flags.dryRun = true;
    }
  }

  return flags;
}

function loadSeedData() {
  const dataPath = resolve(__dirname, 'seed_data.json');
  if (!existsSync(dataPath)) {
    console.error(`ERROR: seed_data.json not found at ${dataPath}`);
    process.exit(1);
  }
  return JSON.parse(readFileSync(dataPath, 'utf8'));
}

async function seedCollection(firestore, collectionName, docs, overwrite, dryRun) {
  const batch = firestore.batch();
  const ref = firestore.collection(collectionName);
  let count = 0;

  for (const doc of docs) {
    const nameField = doc.nameEn || doc.titleEn;
    const snapshot = await ref.where('nameEn', '==', nameField).limit(1).get();

    if (!snapshot.empty && !overwrite) {
      console.log(`  SKIP [${collectionName}] ${nameField} (already exists)`);
      continue;
    }

    const now = new Date();
    const data = { ...doc, createdAt: now, updatedAt: now };

    // Remove metadata fields used only during import
    delete data.durationDays;

    // Resolve category name to ID for products
    if (data.categoryNameEn) {
      const catSnapshot = await firestore
        .collection('categories')
        .where('nameEn', '==', data.categoryNameEn)
        .limit(1)
        .get();

      if (catSnapshot.empty) {
        console.warn(`  WARN [${collectionName}] Category "${data.categoryNameEn}" not found, skipping ${nameField}`);
        continue;
      }
      data.categoryId = catSnapshot.docs[0].id;
      delete data.categoryNameEn;
    }

    // Add date range for offers
    if (data.durationDays === undefined && collectionName === 'offers') {
      delete data.durationDays;
    }

    if (dryRun) {
      console.log(`  DRY-RUN [${collectionName}] ${nameField} -> would ${snapshot.empty ? 'CREATE' : 'UPDATE'}`);
      count++;
      continue;
    }

    if (!snapshot.empty && overwrite) {
      batch.update(snapshot.docs[0].ref, data);
      console.log(`  UPDATE [${collectionName}] ${nameField}`);
    } else {
      const docRef = ref.doc();
      batch.set(docRef, data);
      console.log(`  CREATE [${collectionName}] ${nameField}`);
    }
    count++;
  }

  if (count > 0 && !dryRun) {
    await batch.commit();
    console.log(`  -> ${count} documents committed to "${collectionName}"`);
  } else if (count > 0) {
    console.log(`  -> ${count} documents would be written to "${collectionName}"`);
  } else {
    console.log(`  -> No changes for "${collectionName}"`);
  }
}

async function main() {
  const flags = parseArgs();

  if (!flags.key) {
    console.error('ERROR: Firebase service account key is required');
    console.error('Usage: node scripts/seed/import.mjs --key=path/to/serviceAccount.json');
    console.error('       node scripts/seed/import.mjs -k path/to/serviceAccount.json');
    process.exit(1);
  }

  const keyPath = resolve(flags.key);
  if (!existsSync(keyPath)) {
    console.error(`ERROR: Service account key not found at ${keyPath}`);
    process.exit(1);
  }

  const serviceAccount = JSON.parse(readFileSync(keyPath, 'utf8'));

  admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
  const firestore = admin.firestore();

  // Set a longer timeout for batch writes
  firestore.settings({ ignoreUndefinedProperties: true });

  const data = loadSeedData();
  const { overwrite, dryRun } = flags;

  console.log('=== Firestore Seed Import ===');
  console.log(`Mode: ${dryRun ? 'DRY RUN' : overwrite ? 'OVERWRITE' : 'CREATE IF MISSING'}`);
  console.log('');

  // Order matters: categories first, then weight units, then products, then offers
  for (const [collectionName, docs] of Object.entries(data)) {
    if (!Array.isArray(docs)) continue;
    console.log(`\nSeeding "${collectionName}"...`);
    await seedCollection(firestore, collectionName, docs, overwrite, dryRun);
  }

  console.log('\n=== Import complete ===');
  process.exit(0);
}

main().catch((err) => {
  console.error('Import failed:', err);
  process.exit(1);
});
