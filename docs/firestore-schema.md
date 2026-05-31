# Firestore Schema Specification

> Version: 1.0.0
> Last Updated: 2026-05-31

---

## 1. Collection Overview

| # | Collection | Type | Size Estimate | Real-Time | Primary Reader | Primary Writer |
|---|-----------|------|---------------|-----------|----------------|----------------|
| 1 | `roles` | Lookup | < 10 docs | No | All auth users | Admin only |
| 2 | `users` | Entity | < 10K docs | No | Admin / Self | Admin / Self (limited) |
| 3 | `categories` | Entity | < 500 docs | Yes | All auth users | Admin only |
| 4 | `products` | Entity | < 10K docs | Yes | All auth users | Admin only |
| 5 | `offers` | Entity | < 1K docs | Yes | All auth users | Admin only |
| 6 | `offer_products` | Junction | < 50K docs | No | All auth users | Admin only |
| 7 | `weight_units` | Lookup | < 20 docs | No | All auth users | Admin only |
| 8 | `settings` | Config | < 50 docs | No | All auth users | Admin only |
| 9 | `banners` | Entity | < 50 docs | Yes | All auth users | Admin only |
| 10 | `notifications` | Entity | < 500K docs | No | Owner only | System / Admin |

---

## 2. Collection: `roles`

**Purpose**: Defines available user roles and their permissions.

**Document ID**: Custom string matching role name (`admin`, `customer`).

| Field | Type | Required | Default | Constraints |
|-------|------|----------|---------|-------------|
| `id` | `string` | Yes | — | Document ID. Must match `^[a-z_]+$` |
| `name` | `string` | Yes | — | Human-readable name. Max 50 chars |
| `permissions` | `array<string>` | Yes | `[]` | List of permission keys. Max 50 entries |
| `description` | `string` | No | `null` | Max 200 chars |

### Seed Data

```json
{
  "admin": {
    "id": "admin",
    "name": "Administrator",
    "permissions": [
      "products:create", "products:read", "products:update", "products:delete",
      "categories:create", "categories:read", "categories:update", "categories:delete",
      "offers:create", "offers:read", "offers:update", "offers:delete",
      "banners:create", "banners:read", "banners:update", "banners:delete",
      "users:read", "users:update",
      "settings:read", "settings:update",
      "notifications:create", "notifications:read"
    ],
    "description": "Full system access"
  },
  "customer": {
    "id": "customer",
    "name": "Customer",
    "permissions": [
      "products:read",
      "categories:read",
      "offers:read",
      "banners:read",
      "notifications:read"
    ],
    "description": "Standard customer access"
  }
}
```

---

## 3. Collection: `users`

**Purpose**: Stores user profile data and authentication metadata.

**Document ID**: Firebase Authentication UID.

| Field | Type | Required | Default | Constraints |
|-------|------|----------|---------|-------------|
| `id` | `string` | Yes | — | Firebase Auth UID. Immutable |
| `email` | `string` | Yes | — | Valid email format. Max 255 chars |
| `displayName` | `string` | No | `null` | Max 100 chars |
| `phoneNumber` | `string` | No | `null` | E.164 format. Max 20 chars |
| `photoUrl` | `string` | No | `null` | Valid URL. Max 500 chars |
| `role` | `string` | Yes | `customer` | Must be one of: `admin`, `customer` |
| `isActive` | `bool` | Yes | `true` | Only admins can set to `false` |
| `fcmToken` | `string` | No | `null` | FCM device token. Updated on login |
| `lastLoginAt` | `timestamp` | No | `null` | Updated on each sign-in |
| `createdAt` | `timestamp` | Yes | `server` | Set on document creation |
| `updatedAt` | `timestamp` | Yes | `server` | Updated on every field change |

### Sample Document

```json
{
  "id": "a1b2c3d4e5f6g7h8i9j0k1l2",
  "email": "ahmed@example.com",
  "displayName": "أحمد محمد",
  "phoneNumber": "+966501234567",
  "photoUrl": "https://firebasestorage.googleapis.com/v0/b/fresh-market/o/users%2Fa1b2c3d4e5f6g7h8i9j0k1l2%2Fprofile.jpg",
  "role": "customer",
  "isActive": true,
  "fcmToken": "fM9xZ2Q4...cR7vW1pA3",
  "lastLoginAt": "2026-05-31T10:30:00Z",
  "createdAt": "2026-01-15T08:00:00Z",
  "updatedAt": "2026-05-31T10:30:00Z"
}
```

---

## 4. Collection: `categories`

**Purpose**: Product categorization with Arabic/English names, visibility control, and ordering.

**Document ID**: Auto-generated (`category_XXXXX`).

| Field | Type | Required | Default | Constraints |
|-------|------|----------|---------|-------------|
| `id` | `string` | Yes | — | Auto-generated |
| `nameAr` | `string` | Yes | — | Arabic name. Non-empty. Max 100 chars |
| `nameEn` | `string` | Yes | — | English name. Non-empty. Max 100 chars |
| `imageUrl` | `string` | No | `null` | Firebase Storage URL. Max 500 chars |
| `isVisible` | `bool` | Yes | `true` | Controls display in customer app |
| `sortOrder` | `number` | Yes | `0` | Non-negative integer. 0-based |
| `createdAt` | `timestamp` | Yes | `server` | Set on document creation |
| `updatedAt` | `timestamp` | Yes | `server` | Updated on every field change |

### Sample Document

```json
{
  "id": "category_001",
  "nameAr": "فواكه",
  "nameEn": "Fruits",
  "imageUrl": "https://firebasestorage.googleapis.com/v0/b/fresh-market/o/categories%2Fcategory_001%2Fimage.jpg",
  "isVisible": true,
  "sortOrder": 0,
  "createdAt": "2026-01-01T00:00:00Z",
  "updatedAt": "2026-05-15T14:30:00Z"
}
```

### Typical Query Patterns

```dart
// Customer: visible categories sorted
FirebaseFirestore.instance
  .collection('categories')
  .where('isVisible', isEqualTo: true)
  .orderBy('sortOrder', descending: false)
  .limit(50)
  .snapshots();

// Admin: all categories sorted
FirebaseFirestore.instance
  .collection('categories')
  .orderBy('sortOrder', descending: false)
  .snapshots();
```

---

## 5. Collection: `products`

**Purpose**: Product catalog items with localized content, pricing, and categorization.

**Document ID**: Auto-generated (`product_XXXXX`).

| Field | Type | Required | Default | Constraints |
|-------|------|----------|---------|-------------|
| `id` | `string` | Yes | — | Auto-generated |
| `nameAr` | `string` | Yes | — | Arabic name. Non-empty. Max 200 chars |
| `nameEn` | `string` | Yes | — | English name. Non-empty. Max 200 chars |
| `descriptionAr` | `string` | No | `""` | Arabic description. Max 1000 chars |
| `descriptionEn` | `string` | No | `""` | English description. Max 1000 chars |
| `price` | `number` | Yes | — | Must be >= 0. Max 999999.99 |
| `weight` | `number` | Yes | — | Must be > 0. Max 99999 |
| `weightUnitId` | `string` | Yes | — | Must reference an existing `weight_units` doc |
| `imageUrl` | `string` | No | `null` | Firebase Storage URL. Max 500 chars |
| `imageThumbUrl` | `string` | No | `null` | Thumbnail (200px). Generated via Cloud Function |
| `categoryId` | `string` | Yes | — | Must reference an existing `categories` doc |
| `isFeatured` | `bool` | Yes | `false` | Featured products appear on home screen |
| `isAvailable` | `bool` | Yes | `true` | Controls purchase eligibility |
| `createdAt` | `timestamp` | Yes | `server` | Set on document creation |
| `updatedAt` | `timestamp` | Yes | `server` | Updated on every field change |

### Sample Document

```json
{
  "id": "product_001",
  "nameAr": "تفاح أحمر",
  "nameEn": "Red Apple",
  "descriptionAr": "تفاح أحمر طازج من مزارع محلية. غني بالفيتامينات والمعادن.",
  "descriptionEn": "Fresh red apples from local farms. Rich in vitamins and minerals.",
  "price": 4.99,
  "weight": 1.0,
  "weightUnitId": "weight_unit_kg",
  "imageUrl": "https://firebasestorage.googleapis.com/v0/b/fresh-market/o/products%2Fproduct_001%2Fimage.jpg",
  "imageThumbUrl": "https://firebasestorage.googleapis.com/v0/b/fresh-market/o/products%2Fproduct_001%2Fthumb_200.jpg",
  "categoryId": "category_001",
  "isFeatured": true,
  "isAvailable": true,
  "createdAt": "2026-01-10T09:00:00Z",
  "updatedAt": "2026-05-30T16:45:00Z"
}
```

### Typical Query Patterns

```dart
// Home: featured + available products (last 20 updated)
FirebaseFirestore.instance
  .collection('products')
  .where('isFeatured', isEqualTo: true)
  .where('isAvailable', isEqualTo: true)
  .orderBy('updatedAt', descending: true)
  .limit(20)
  .snapshots();

// Category: products in category, paginated
FirebaseFirestore.instance
  .collection('products')
  .where('categoryId', isEqualTo: 'category_001')
  .where('isAvailable', isEqualTo: true)
  .orderBy('price')
  .limit(20)
  .startAfterDocument(lastDoc)
  .get();

// Admin: all products, paginated
FirebaseFirestore.instance
  .collection('products')
  .orderBy('updatedAt', descending: true)
  .limit(50)
  .startAfterDocument(lastDoc)
  .get();
```

---

## 6. Collection: `offers`

**Purpose**: Promotional campaigns with date validity and localized content.

**Document ID**: Auto-generated (`offer_XXXXX`).

| Field | Type | Required | Default | Constraints |
|-------|------|----------|---------|-------------|
| `id` | `string` | Yes | — | Auto-generated |
| `titleAr` | `string` | Yes | — | Arabic title. Non-empty. Max 200 chars |
| `titleEn` | `string` | Yes | — | English title. Non-empty. Max 200 chars |
| `descriptionAr` | `string` | No | `""` | Arabic description. Max 500 chars |
| `descriptionEn` | `string` | No | `""` | English description. Max 500 chars |
| `imageUrl` | `string` | No | `null` | Firebase Storage URL. Max 500 chars |
| `isActive` | `bool` | Yes | `false` | Manual toggle for offer activation |
| `startDate` | `timestamp` | Yes | — | Must be before `endDate` |
| `endDate` | `timestamp` | Yes | — | Must be after `startDate` |
| `createdAt` | `timestamp` | Yes | `server` | Set on document creation |
| `updatedAt` | `timestamp` | Yes | `server` | Updated on every field change |

### Sample Document

```json
{
  "id": "offer_001",
  "titleAr": "عرض الصيف",
  "titleEn": "Summer Sale",
  "descriptionAr": "خصم يصل إلى 30% على جميع الفواكه الطازجة. عرض لفترة محدودة!",
  "descriptionEn": "Up to 30% off on all fresh fruits. Limited time offer!",
  "imageUrl": "https://firebasestorage.googleapis.com/v0/b/fresh-market/o/offers%2Foffer_001%2Fimage.jpg",
  "isActive": true,
  "startDate": "2026-06-01T00:00:00Z",
  "endDate": "2026-06-30T23:59:59Z",
  "createdAt": "2026-05-20T10:00:00Z",
  "updatedAt": "2026-05-25T08:15:00Z"
}
```

### Typical Query Patterns

```dart
// Home: currently active offers
FirebaseFirestore.instance
  .collection('offers')
  .where('isActive', isEqualTo: true)
  .where('endDate', isGreaterThanOrEqualTo: Timestamp.now())
  .orderBy('endDate', descending: false)
  .limit(10)
  .snapshots();

// Admin: all offers, newest first
FirebaseFirestore.instance
  .collection('offers')
  .orderBy('createdAt', descending: true)
  .snapshots();
```

---

## 7. Collection: `offer_products`

**Purpose**: Many-to-many junction between offers and products.

**Document ID**: Auto-generated (`{offerId}_{productId}`).

| Field | Type | Required | Default | Constraints |
|-------|------|----------|---------|-------------|
| `id` | `string` | Yes | — | Compound key: `{offerId}_{productId}` |
| `offerId` | `string` | Yes | — | Must reference an existing `offers` doc |
| `productId` | `string` | Yes | — | Must reference an existing `products` doc |
| `createdAt` | `timestamp` | Yes | `server` | Set on document creation |

### Sample Document

```json
{
  "id": "offer_001_product_001",
  "offerId": "offer_001",
  "productId": "product_001",
  "createdAt": "2026-05-20T10:00:00Z"
}
```

### Typical Query Patterns

```dart
// All products in an offer
FirebaseFirestore.instance
  .collection('offer_products')
  .where('offerId', isEqualTo: 'offer_001')
  .get()
  .then((snapshot) {
    final productIds = snapshot.docs.map((d) => d.data()['productId'] as String).toList();
    // Then fetch products via `whereIn`
    return FirebaseFirestore.instance
      .collection('products')
      .where(FieldPath.documentId, whereIn: productIds)
      .get();
  });

// All offers containing a product
FirebaseFirestore.instance
  .collection('offer_products')
  .where('productId', isEqualTo: 'product_001')
  .get();
```

### Performance Optimization for Home Screen
To avoid the N+1 query pattern, the repository layer should batch-load offer products:
1. Query `offer_products` for the offer.
2. Collect all `productId` values.
3. Single `whereIn` query on `products` collection (max 10 per batch).
4. Map results back to the offer.

---

## 8. Collection: `weight_units`

**Purpose**: Lookup table for product weight measurement units.

**Document ID**: Custom string (`weight_unit_kg`, `weight_unit_g`, `weight_unit_lb`).

| Field | Type | Required | Default | Constraints |
|-------|------|----------|---------|-------------|
| `id` | `string` | Yes | — | Document ID. Must be unique |
| `nameAr` | `string` | Yes | — | Arabic name (e.g., `كيلوغرام`). Max 50 chars |
| `nameEn` | `string` | Yes | — | English name (e.g., `Kilogram`). Max 50 chars |
| `abbr` | `string` | Yes | — | Abbreviation (e.g., `kg`). Max 10 chars |
| `sortOrder` | `number` | Yes | `0` | Display order. Non-negative |

### Sample Document

```json
{
  "id": "weight_unit_kg",
  "nameAr": "كيلوغرام",
  "nameEn": "Kilogram",
  "abbr": "kg",
  "sortOrder": 0
}
```

### Seed Data

```json
[
  {
    "id": "weight_unit_kg",
    "nameAr": "كيلوغرام",
    "nameEn": "Kilogram",
    "abbr": "kg",
    "sortOrder": 0
  },
  {
    "id": "weight_unit_g",
    "nameAr": "غرام",
    "nameEn": "Gram",
    "abbr": "g",
    "sortOrder": 1
  },
  {
    "id": "weight_unit_lb",
    "nameAr": "رطل",
    "nameEn": "Pound",
    "abbr": "lb",
    "sortOrder": 2
  }
]
```

---

## 9. Collection: `settings`

**Purpose**: Application-wide configuration key-value store.

**Document ID**: Setting key string (e.g., `store_name`, `currency`, `tax_rate`).

| Field | Type | Required | Default | Constraints |
|-------|------|----------|---------|-------------|
| `id` | `string` | Yes | — | Setting key. Must match `^[a-z_]+$` |
| `value` | `any` | Yes | — | Must match declared `type` below |
| `type` | `string` | Yes | — | One of: `string`, `number`, `bool`, `json` |
| `description` | `string` | No | `null` | Human-readable description. Max 200 chars |
| `updatedAt` | `timestamp` | Yes | `server` | Updated on value change |

### Sample Documents

```json
// store_name
{
  "id": "store_name",
  "value": "السوق الطازج",
  "type": "string",
  "description": "Store name displayed in UI headers",
  "updatedAt": "2026-01-01T00:00:00Z"
}

// currency
{
  "id": "currency",
  "value": "SAR",
  "type": "string",
  "description": "ISO 4217 currency code",
  "updatedAt": "2026-01-01T00:00:00Z"
}

// tax_rate
{
  "id": "tax_rate",
  "value": 15.0,
  "type": "number",
  "description": "VAT tax rate as percentage",
  "updatedAt": "2026-01-01T00:00:00Z"
}

// is_maintenance_mode
{
  "id": "is_maintenance_mode",
  "value": false,
  "type": "bool",
  "description": "When true, customers see maintenance page",
  "updatedAt": "2026-01-01T00:00:00Z"
}
```

---

## 10. Collection: `banners`

**Purpose**: Promotional banners displayed as a carousel on the home screen.

**Document ID**: Auto-generated (`banner_XXXXX`).

| Field | Type | Required | Default | Constraints |
|-------|------|----------|---------|-------------|
| `id` | `string` | Yes | — | Auto-generated |
| `titleAr` | `string` | No | `""` | Arabic overlay title. Max 100 chars |
| `titleEn` | `string` | No | `""` | English overlay title. Max 100 chars |
| `imageUrl` | `string` | Yes | — | Firebase Storage URL. Max 500 chars |
| `linkUrl` | `string` | No | `null` | Deep link (e.g., `/offers/offer_001`). Max 500 chars |
| `sortOrder` | `number` | Yes | `0` | Display order. Non-negative |
| `isActive` | `bool` | Yes | `true` | Controls display on home screen |
| `createdAt` | `timestamp` | Yes | `server` | Set on document creation |
| `updatedAt` | `timestamp` | Yes | `server` | Updated on every field change |

### Sample Document

```json
{
  "id": "banner_001",
  "titleAr": "عروض الصيف الجديدة",
  "titleEn": "New Summer Deals",
  "imageUrl": "https://firebasestorage.googleapis.com/v0/b/fresh-market/o/banners%2Fbanner_001%2Fimage.jpg",
  "linkUrl": "/offers/offer_001",
  "sortOrder": 0,
  "isActive": true,
  "createdAt": "2026-05-01T00:00:00Z",
  "updatedAt": "2026-05-28T12:00:00Z"
}
```

### Typical Query Pattern

```dart
FirebaseFirestore.instance
  .collection('banners')
  .where('isActive', isEqualTo: true)
  .orderBy('sortOrder', descending: false)
  .limit(10)
  .snapshots();
```

---

## 11. Collection: `notifications`

**Purpose**: In-app notification history for push and in-app messages.

**Document ID**: Auto-generated.

| Field | Type | Required | Default | Constraints |
|-------|------|----------|---------|-------------|
| `id` | `string` | Yes | — | Auto-generated |
| `userId` | `string` | Yes | — | Target user's Firebase Auth UID |
| `title` | `string` | Yes | — | Notification title. Max 200 chars |
| `body` | `string` | Yes | — | Notification body. Max 500 chars |
| `type` | `string` | Yes | — | One of: `offer`, `product`, `system`, `order` |
| `data` | `map` | No | `{}` | Arbitrary JSON payload |
| `isRead` | `bool` | Yes | `false` | Read status |
| `createdAt` | `timestamp` | Yes | `server` | Set on document creation |

### Sample Document

```json
{
  "id": "notif_001",
  "userId": "a1b2c3d4e5f6g7h8i9j0k1l2",
  "title": "عرض جديد!",
  "body": "تفقد عرض الصيف الجديد - خصم يصل إلى 30% على الفواكه!",
  "type": "offer",
  "data": {
    "offerId": "offer_001",
    "deepLink": "/offers/offer_001"
  },
  "isRead": false,
  "createdAt": "2026-05-31T10:00:00Z"
}
```

### Typical Query Pattern

```dart
FirebaseFirestore.instance
  .collection('notifications')
  .where('userId', isEqualTo: auth.currentUser!.uid)
  .orderBy('createdAt', descending: true)
  .limit(50)
  .snapshots();
```

---

## 12. Complete Index Specification

### Single-Field Indexes (automatic, no action needed)
All fields are automatically indexed by Firestore. However, the following **composite indexes** must be created manually:

### Composite Indexes (must create in Firebase Console)

| # | Collection | Fields | Query Pattern |
|---|-----------|--------|---------------|
| 1 | `products` | `categoryId` ASC, `isAvailable` ASC | Products by category, filter available |
| 2 | `products` | `isFeatured` ASC, `isAvailable` ASC | Home: featured + available |
| 3 | `products` | `isFeatured` ASC, `isAvailable` ASC, `updatedAt` DESC | Home: featured + available, sorted by update |
| 4 | `products` | `categoryId` ASC, `isAvailable` ASC, `price` ASC | Category page: available, sorted by price |
| 5 | `offers` | `isActive` ASC, `endDate` ASC | Active offers ending soon |
| 6 | `offers` | `isActive` ASC, `endDate` DESC | Active offers, newest end dates first |
| 7 | `offers` | `isActive` ASC, `startDate` ASC, `endDate` ASC | Active within date range |
| 8 | `categories` | `isVisible` ASC, `sortOrder` ASC | Visible categories sorted |
| 9 | `notifications` | `userId` ASC, `createdAt` DESC | User notifications, newest first |
| 10 | `offer_products` | `offerId` ASC, `productId` ASC | Products in an offer |
| 11 | `banners` | `isActive` ASC, `sortOrder` ASC | Active banners sorted |

### Firestore Console Index Creation

Navigate to: **Firebase Console** → **Firestore** → **Indexes** → **Composite** → **Create Index**

For each index, configure:
- **Collection**: As specified above
- **Fields**: As specified above, with matching sort order
- **Query scope**: Collection

---

## 13. Security Rules Specification

### Full Security Rules

```javascript
rules_version = '2';
service cloud.firestore {

  // ─── Helper Functions ──────────────────────────────────────────

  function isAuthenticated() {
    return request.auth != null;
  }

  function getRole() {
    return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role;
  }

  function isAdmin() {
    return isAuthenticated() && getRole() == 'admin';
  }

  function isOwner(userId) {
    return request.auth != null && request.auth.uid == userId;
  }

  function isFieldType(field, type) {
    return request.resource.data.keys().hasAll([field])
      && request.resource.data[field] is type;
  }

  function hasRequiredFields(fields) {
    return request.resource.data.keys().hasAll(fields);
  }

  function hasTimestamps() {
    return hasRequiredFields(['createdAt', 'updatedAt'])
      && request.resource.data.createdAt == request.time
      && request.resource.data.updatedAt == request.time;
  }

  function validateProduct() {
    return hasRequiredFields(['nameAr', 'nameEn', 'price', 'weight', 'categoryId', 'weightUnitId'])
      && request.resource.data.nameAr is string
      && request.resource.data.nameAr.size() > 0
      && request.resource.data.nameAr.size() <= 200
      && request.resource.data.nameEn is string
      && request.resource.data.nameEn.size() > 0
      && request.resource.data.nameEn.size() <= 200
      && request.resource.data.price is number
      && request.resource.data.price >= 0
      && request.resource.data.price <= 999999.99
      && request.resource.data.weight is number
      && request.resource.data.weight > 0
      && request.resource.data.weight <= 99999;
  }

  function validateCategory() {
    return hasRequiredFields(['nameAr', 'nameEn'])
      && request.resource.data.nameAr is string
      && request.resource.data.nameAr.size() > 0
      && request.resource.data.nameAr.size() <= 100
      && request.resource.data.nameEn is string
      && request.resource.data.nameEn.size() > 0
      && request.resource.data.nameEn.size() <= 100;
  }

  function validateOffer() {
    return hasRequiredFields(['titleAr', 'titleEn', 'startDate', 'endDate'])
      && request.resource.data.titleAr is string
      && request.resource.data.titleAr.size() > 0
      && request.resource.data.titleAr.size() <= 200
      && request.resource.data.titleEn is string
      && request.resource.data.titleEn.size() > 0
      && request.resource.data.titleEn.size() <= 200
      && request.resource.data.startDate is timestamp
      && request.resource.data.endDate is timestamp
      && request.resource.data.startDate < request.resource.data.endDate;
  }

  function validateBanner() {
    return hasRequiredFields(['imageUrl'])
      && request.resource.data.imageUrl is string;
  }

  function validateSetting() {
    return hasRequiredFields(['value', 'type'])
      && request.resource.data.type in ['string', 'number', 'bool', 'json'];
  }

  function validateUser() {
    return hasRequiredFields(['email', 'role'])
      && request.resource.data.email is string
      && request.resource.data.email.matches('^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$')
      && request.resource.data.role in ['admin', 'customer'];
  }

  // ─── Match Rules ───────────────────────────────────────────────

  match /databases/{database}/documents {

    // Deny all by default
    match /{document=**} {
      allow read, write: if false;
    }

    // ── roles ──────────────────────────────────────────────────
    match /roles/{roleId} {
      allow read: if isAuthenticated();
      allow create: if isAdmin() && validateRole();
      allow update: if isAdmin() && validateRole();
      allow delete: if isAdmin();
    }

    // ── users ──────────────────────────────────────────────────
    match /users/{userId} {
      allow read: if isAuthenticated() && (isAdmin() || request.auth.uid == userId);
      allow create: if request.auth != null
        && request.auth.uid == userId
        && validateUser()
        && request.resource.data.role == 'customer';  // self-registration only as customer
      allow update: if isAuthenticated()
        && (
          // Admin can update any user
          (isAdmin() && validateUser())
          ||
          // Self can update limited fields
          (request.auth.uid == userId
            && request.resource.data.diff(resource.data).affectedKeys()
              .hasOnly(['displayName', 'phoneNumber', 'photoUrl', 'fcmToken', 'lastLoginAt'])
          )
        );
      allow delete: if isAdmin();
    }

    // ── categories ─────────────────────────────────────────────
    match /categories/{categoryId} {
      allow read: if isAuthenticated();
      allow create: if isAdmin() && validateCategory();
      allow update: if isAdmin() && validateCategory();
      allow delete: if isAdmin();
    }

    // ── products ───────────────────────────────────────────────
    match /products/{productId} {
      allow read: if isAuthenticated();
      allow create: if isAdmin() && validateProduct();
      allow update: if isAdmin() && validateProduct();
      allow delete: if isAdmin();
    }

    // ── offers ─────────────────────────────────────────────────
    match /offers/{offerId} {
      allow read: if isAuthenticated();
      allow create: if isAdmin() && validateOffer();
      allow update: if isAdmin() && validateOffer();
      allow delete: if isAdmin();
    }

    // ── offer_products ─────────────────────────────────────────
    match /offer_products/{junctionId} {
      allow read: if isAuthenticated();
      allow create: if isAdmin()
        && hasRequiredFields(['offerId', 'productId']);
      allow delete: if isAdmin();
      // No update — junction records are immutable after creation
    }

    // ── weight_units ───────────────────────────────────────────
    match /weight_units/{unitId} {
      allow read: if isAuthenticated();
      allow create: if isAdmin()
        && hasRequiredFields(['nameAr', 'nameEn', 'abbr']);
      allow update: if isAdmin();
      allow delete: if isAdmin();
    }

    // ── settings ───────────────────────────────────────────────
    match /settings/{settingKey} {
      allow read: if isAuthenticated();
      allow create: if isAdmin() && validateSetting();
      allow update: if isAdmin() && validateSetting();
      allow delete: if isAdmin();
    }

    // ── banners ────────────────────────────────────────────────
    match /banners/{bannerId} {
      allow read: if isAuthenticated();
      allow create: if isAdmin() && validateBanner();
      allow update: if isAdmin() && validateBanner();
      allow delete: if isAdmin();
    }

    // ── notifications ──────────────────────────────────────────
    match /notifications/{notificationId} {
      allow read: if isAuthenticated()
        && resource.data.userId == request.auth.uid;
      allow create: if isAdmin() || isSystemFunction();
      allow update: if isAuthenticated()
        && resource.data.userId == request.auth.uid
        && request.resource.data.diff(resource.data).affectedKeys()
             .hasOnly(['isRead']);
      allow delete: if false;  // Notifications are never deleted by clients
    }
  }
}
```

### Security Rule Notes

1. **Admin elevation**: Only Firebase console or Cloud Functions with admin SDK can create admin users. Self-registration always assigns `role: 'customer'`.
2. **Field-level security for users**: Self-service users can only update `displayName`, `phoneNumber`, `photoUrl`, `fcmToken`, and `lastLoginAt`. Role changes are admin-only.
3. **Notification isolation**: Users can only read notifications where `userId == auth.uid`. Cross-user notification access is denied.
4. **Offer products immutability**: Junction documents are create/delete only. Updates are not allowed to prevent referential integrity issues.
5. **Timestamps**: `createdAt` and `updatedAt` must be set to `request.time` (server timestamp) on create. `updatedAt` must be `request.time` on update.
6. **Cloud Functions**: For system-level operations (sending notifications, deactivating expired offers), use Firebase Admin SDK which bypasses security rules.

---

## 14. Data Validation Rules

### Client-Side Validation (before write)

| Field Pattern | Validation | Location |
|--------------|------------|----------|
| `nameAr`, `titleAr` | Non-empty, max N chars, contains Arabic script | DTO `.validate()` |
| `nameEn`, `titleEn` | Non-empty, max N chars | DTO `.validate()` |
| `price` | >= 0, <= 999999.99, max 2 decimal places | DTO |
| `weight` | > 0, <= 99999, max 3 decimal places | DTO |
| `email` | Regex: RFC 5322 simplified | Auth form |
| `imageUrl` | Must start with `https://firebasestorage.googleapis.com` | DTO |
| `role` | Must be one of `admin`, `customer` | Enum check |
| `startDate` < `endDate` | Cross-field comparison | Offer form |
| `categoryId` | Must match existing category | Repository |
| `weightUnitId` | Must match existing weight unit | Repository |

### Server-Side Validation (Firestore rules)

See `validateProduct()`, `validateCategory()`, `validateOffer()`, etc. in the Security Rules above.

### Cloud Functions Validation (critical operations)

| Operation | Trigger | Validation |
|-----------|---------|------------|
| Delete category | `onDelete` | Reassign products to "uncategorized" or block if products exist |
| Delete product | `onDelete` | Remove all `offer_products` entries referencing this product |
| End offer date passed | Scheduled (daily) | Set `isActive = false` where `endDate < now()` |
| New user registered | `onCreate` (Auth) | Create `users` document with `role: 'customer'` |
| Image uploaded | `onFinalize` (Storage) | Generate thumbnail at 200px width |

---

## 15. Storage Structure

Firebase Storage mirrors Firestore collections for image organization:

```
/products/{productId}/image.jpg
/products/{productId}/thumb_200.jpg
/categories/{categoryId}/image.jpg
/offers/{offerId}/image.jpg
/banners/{bannerId}/image.jpg
/users/{userId}/profile.jpg
```

### Image Constraints

| Image Type | Max Size | Format | Thumbnail | Aspect Ratio |
|-----------|----------|--------|-----------|--------------|
| Product | 5 MB | JPEG/PNG/WebP | 200px width | 1:1 |
| Category | 2 MB | JPEG/PNG/WebP | — | 4:3 |
| Offer | 5 MB | JPEG/PNG/WebP | — | 16:9 |
| Banner | 5 MB | JPEG/PNG/WebP | — | 21:9 |
| User Profile | 2 MB | JPEG/PNG/WebP | 100px width | 1:1 |

---

## 16. Cost Considerations

| Operation | Estimated Reads (10K products, 500 users/day) |
|-----------|-----------------------------------------------|
| Home screen load (per user) | ~35 reads (20 products + 10 offers + 10 banners + visible categories) |
| Category product list (per category) | ~22 reads (20 products + 1 category + weight unit data) |
| Offer detail view (per view) | ~12 reads (1 offer + 10 offer_products + 10 products via whereIn) |
| Admin dashboard load | ~100+ reads (depends on active section) |
| Daily total estimate | ~50,000 - 100,000 reads (500 active users) |

### Optimization Strategies

1. **Local caching**: Cache `weight_units` and `roles` indefinitely (refreshed on app restart).
2. **Product caching**: Cache product list results for 30 seconds.
3. **Image CDN**: Firebase Storage automatically uses Google CDN for cached image delivery.
4. **Pagination**: All list queries use cursor-based pagination with `limit()`.
5. **Selective reads**: Use `.select()` to fetch only needed fields when reading large documents.
