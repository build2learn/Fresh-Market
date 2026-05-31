# Firestore Data Modeling Skill

## Design Principles

### 1. Denormalization
- Duplicate data where read performance matters.
- Store product name in offers to avoid joins.
- Accept data duplication for read efficiency.

### 2. Reference Fields
- Store references as `DocumentReference` types.
- Store parent ID as string for simple lookups.
- Example: `categoryId: categories/{categoryId}`

### 3. Composite Keys
- Use compound document IDs for many-to-many relationships.
- Example: `offerId_productId` as document ID in `offer_products`.

### 4. Timestamps
- Use `FieldValue.serverTimestamp()` for all timestamps.
- Query ordering by `createdAt` or `updatedAt` for real-time feeds.

## Collection Relationships

### One-to-Many
```
category ──has many──► products via products.categoryId
```

### Many-to-Many
```
offer ◄──offer_products──► product
offer_products is a junction collection with offerId + productId
```

## Query Patterns

### Get visible categories sorted
```dart
FirebaseFirestore.instance
  .collection('categories')
  .where('isVisible', isEqualTo: true)
  .orderBy('sortOrder')
  .snapshots();
```

### Get featured available products
```dart
FirebaseFirestore.instance
  .collection('products')
  .where('isFeatured', isEqualTo: true)
  .where('isAvailable', isEqualTo: true)
  .snapshots();
```

### Get active offers
```dart
FirebaseFirestore.instance
  .collection('offers')
  .where('isActive', isEqualTo: true)
  .where('startDate', isLessThanOrEqualTo: Timestamp.now())
  .where('endDate', isGreaterThanOrEqualTo: Timestamp.now())
  .snapshots();
```

### Get user notifications
```dart
FirebaseFirestore.instance
  .collection('notifications')
  .where('userId', isEqualTo: userRef)
  .orderBy('createdAt', descending: true)
  .limit(50)
  .snapshots();
```

## Offline Persistence
```dart
// Enable offline persistence
FirebaseFirestore.instance.settings = Settings(persistenceEnabled: true);

// Firestore automatically caches documents for offline access.
// Pending writes are queued locally and synced when online.
```

## Batch Operations
```dart
final batch = FirebaseFirestore.instance.batch();
batch.set(documentRef, data);
batch.update(documentRef, {'field': value});
batch.delete(documentRef);
await batch.commit();
```

## Transactions
```dart
FirebaseFirestore.instance.runTransaction((transaction) async {
  final snapshot = await transaction.get(documentRef);
  if (snapshot.exists) {
    transaction.update(documentRef, {'counter': snapshot.get('counter') + 1});
  }
});
```
