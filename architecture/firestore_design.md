# Firestore Database Design

## Collection Schema

### `roles`
| Field      | Type   | Description             |
|------------|--------|-------------------------|
| `id`       | string | Role ID                 |
| `name`     | string | Role name (admin/customer) |
| `permissions` | array | List of permission strings |

### `users`
| Field             | Type   | Description                    |
|-------------------|--------|--------------------------------|
| `id`              | string | Firebase Auth UID               |
| `email`           | string | User email                     |
| `displayName`     | string | User display name              |
| `phoneNumber`     | string | Optional phone number          |
| `role`            | string | Role name: `admin` or `customer` |
| `isActive`        | bool   | Account active status          |
| `createdAt`       | timestamp | Account creation date        |
| `updatedAt`       | timestamp | Last profile update          |
| `fcmToken`        | string | Firebase Cloud Messaging token |

### `categories`
| Field         | Type      | Description                     |
|---------------|-----------|---------------------------------|
| `id`          | string    | Auto-generated document ID      |
| `nameAr`      | string    | Arabic category name            |
| `nameEn`      | string    | English category name           |
| `imageUrl`    | string    | Category image URL              |
| `isVisible`   | bool      | Visibility toggle               |
| `sortOrder`   | number    | Display order (0-based)         |
| `createdAt`   | timestamp | Creation date                   |
| `updatedAt`   | timestamp | Last update date                |

### `products`
| Field          | Type      | Description                      |
|----------------|-----------|----------------------------------|
| `id`           | string    | Auto-generated document ID       |
| `nameAr`       | string    | Arabic product name              |
| `nameEn`       | string    | English product name             |
| `descriptionAr`| string    | Arabic product description       |
| `descriptionEn`| string    | English product description      |
| `price`        | number    | Product price                    |
| `weight`       | number    | Product weight value             |
| `weightUnitId` | ref       | Reference to weight_units doc    |
| `imageUrl`     | string    | Product image URL                |
| `categoryId`   | ref       | Reference to categories doc      |
| `isFeatured`   | bool      | Featured flag                    |
| `isAvailable`  | bool      | Availability flag                |
| `createdAt`    | timestamp | Creation date                    |
| `updatedAt`    | timestamp | Last update date                 |

### `offers`
| Field          | Type      | Description                      |
|----------------|-----------|----------------------------------|
| `id`           | string    | Auto-generated document ID       |
| `titleAr`      | string    | Arabic offer title               |
| `titleEn`      | string    | English offer title              |
| `descriptionAr`| string    | Arabic offer description         |
| `descriptionEn`| string    | English offer description        |
| `imageUrl`     | string    | Offer image URL                  |
| `isActive`     | bool      | Active flag                      |
| `startDate`    | timestamp | Offer start date                 |
| `endDate`      | timestamp | Offer end date                   |
| `createdAt`    | timestamp | Creation date                    |
| `updatedAt`    | timestamp | Last update date                 |

### `offer_products`
| Field      | Type      | Description                    |
|------------|-----------|--------------------------------|
| `id`       | string    | Auto-generated document ID     |
| `offerId`  | ref       | Reference to offers document   |
| `productId`| ref       | Reference to products document |
| `createdAt`| timestamp | Association date               |

### `weight_units`
| Field   | Type   | Description               |
|---------|--------|---------------------------|
| `id`    | string | Auto-generated document ID |
| `nameAr`| string | Arabic unit name (كجم)    |
| `nameEn`| string | English unit name (kg)    |
| `abbr`  | string | Abbreviation (kg, g, lb)  |
| `sortOrder` | number | Display order        |

### `settings`
| Field   | Type   | Description               |
|---------|--------|---------------------------|
| `id`    | string | Setting key               |
| `value` | any    | Setting value             |
| `type`  | string | Value type (string, number, bool) |

### `banners`
| Field         | Type      | Description                     |
|---------------|-----------|---------------------------------|
| `id`          | string    | Auto-generated document ID      |
| `titleAr`     | string    | Arabic banner title             |
| `titleEn`     | string    | English banner title            |
| `imageUrl`    | string    | Banner image URL                |
| `linkUrl`     | string    | Optional deep link on tap       |
| `sortOrder`   | number    | Display order (0-based)         |
| `isActive`    | bool      | Active flag                     |
| `createdAt`   | timestamp | Creation date                   |
| `updatedAt`   | timestamp | Last update date                |

### `notifications`
| Field      | Type      | Description                    |
|------------|-----------|--------------------------------|
| `id`       | string    | Auto-generated document ID     |
| `userId`   | string    | Target user UID (string, not ref) |
| `title`    | string    | Notification title             |
| `body`     | string    | Notification body              |
| `type`     | string    | Notification type (offer, product, system) |
| `data`     | map       | Additional payload data        |
| `isRead`   | bool      | Read status                    |
| `createdAt`| timestamp | Creation date                  |

## Indexes

### Required composite indexes:
1. `products` - `categoryId` ASC, `isAvailable` ASC
2. `products` - `isFeatured` ASC, `isAvailable` ASC
3. `offers` - `isActive` ASC, `startDate` ASC, `endDate` ASC
4. `categories` - `isVisible` ASC, `sortOrder` ASC
5. `notifications` - `userId` ASC, `createdAt` DESC
6. `offer_products` - `offerId` ASC, `productId` ASC
7. `products` - `isFeatured` ASC, `isAvailable` ASC, `updatedAt` DESC
8. `offers` - `isActive` ASC, `endDate` DESC
9. `products` - `categoryId` ASC, `isAvailable` ASC, `price` ASC
10. `banners` - `isActive` ASC, `sortOrder` ASC

## Real-Time Listeners with Limits
- Products (home): `.where('isFeatured', isEqualTo: true).where('isAvailable', isEqualTo: true).limit(20).snapshots()`
- Products (category): `.where('categoryId', isEqualTo: catId).where('isAvailable', isEqualTo: true).limit(20).snapshots()`
- Offers (home): `.where('isActive', isEqualTo: true).where('endDate', isGreaterThanOrEqualTo: now).limit(10).snapshots()`
- Categories: `.where('isVisible', isEqualTo: true).orderBy('sortOrder').limit(50).snapshots()`
- Banners: `.where('isActive', isEqualTo: true).orderBy('sortOrder').limit(10).snapshots()`
- All queries use `limit()` to control read costs.

## Pagination Strategy
- All product list queries use cursor-based pagination.
- Repository methods accept `{required int limit, DocumentSnapshot? lastDoc}` parameters.
- `PaginatedResult<T>` wrapper returns `{List<T> items, DocumentSnapshot? lastDoc, bool hasMore}`.
- Default page size: 20 (mobile), 50 (web/tablet).
