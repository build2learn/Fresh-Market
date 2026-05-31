# Firestore Rules & Constraints

## Schema Constraints

### Document Structure
- Every document must have `createdAt` and `updatedAt` timestamps.
- All boolean fields must have explicit defaults in security rules.
- Reference fields must use document paths, not strings.
- Timestamps must use Firestore `Timestamp` type.

### Field Constraints

#### `users`
- `email`: Must match email regex pattern. Required. Unique.
- `role`: String field. Must be one of: `admin`, `customer`. Default `customer`.
- `isActive`: Default `true`. Only admins can deactivate.

#### `categories`
- `nameAr`: Required. Non-empty. Max 100 chars.
- `nameEn`: Required. Non-empty. Max 100 chars.
- `isVisible`: Default `true`.
- `sortOrder`: Non-negative integer. Default 0.

#### `products`
- `nameAr`: Required. Non-empty. Max 200 chars.
- `nameEn`: Required. Non-empty. Max 200 chars.
- `price`: Required. Must be >= 0.
- `weight`: Required. Must be > 0.
- `weightUnitId`: Must reference an existing document in `weight_units`.
- `categoryId`: Must reference an existing document in `categories`.
- `isAvailable`: Default `true`.
- `isFeatured`: Default `false`.

#### `offers`
- `titleAr`: Required. Non-empty. Max 200 chars.
- `titleEn`: Required. Non-empty. Max 200 chars.
- `startDate`: Required. Must be before `endDate`.
- `endDate`: Required. Must be after `startDate`.
- `isActive`: Default `false`.

#### `offer_products`
- `offerId`: Must reference an existing document in `offers`.
- `productId`: Must reference an existing document in `products`.
- Composite uniqueness: `offerId + productId` pair must be unique.

## Security Rules - Operational Constraints

### Security Rules Functions
```
function isAuthenticated() {
  return request.auth != null;
}

function getRole() {
  return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role;
}

function isAdmin() {
  return isAuthenticated() && getRole() == 'admin';
}

function isCustomer() {
  return isAuthenticated() && getRole() == 'customer';
}

function isOwner(userId) {
  return request.auth.uid == userId;
}
```

### Write Validation
```
function validateProduct() {
  return request.resource.data.keys().hasAll(['nameAr', 'nameEn', 'price', 'weight'])
    && request.resource.data.nameAr is string
    && request.resource.data.nameEn is string
    && request.resource.data.price is number
    && request.resource.data.price >= 0
    && request.resource.data.weight is number
    && request.resource.data.weight > 0;
}
```

## Index Constraints
- Composite indexes must be created manually in Firebase Console.
- Array-membership queries are not used (use `where` with `in` instead).
- Maximum 30 composite indexes per Firebase project.
