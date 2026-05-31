# ADR-004: Architecture Review Report

## Status
Review Complete - Recommendations Pending Approval

## Review Scope
Comprehensive architectural review across six dimensions: Scalability, Firestore Design, Localization, Security, Performance, and Requirements Coverage.

---

## 1. Scalability Issues

### S1 - CRITICAL - Missing Pagination Strategy
**File**: `firestore_design.md`, `requirements.md` (NFR1.3)
**Description**: The architecture specifies 20 items per page for pagination but provides no pagination strategy in the data layer. All product queries lack `limit()` and cursor-based pagination. Loading 10,000 products in a single query will exhaust Firestore read budgets and cause memory pressure on mobile devices.
**Recommendation**: Add cursor-based pagination to all product queries. Define `PaginatedResult<T>` in core types. Repository methods should accept `lastDocument` parameter. Firestore queries must use `.limit(pageSize)` and `.startAfterDocument(lastDoc)`. Update `get_products_usecase.dart` to accept pagination parameters.

### S2 - CRITICAL - No Query Limits on Real-Time Listeners
**File**: `firestore_design.md` (Real-Time Listeners section)
**Description**: Real-time `.snapshots()` on `products` (10K), `categories`, and `offers` collections have no `.limit()` clauses. Every client will receive the full collection on every change, causing massive bandwidth and read cost at scale.
**Recommendation**: Apply `.limit(visibleLimit)` on home screen queries (e.g., 20 featured products). Use collection group queries with filters. For admin views, implement server-side pagination even with real-time listeners by using `.limit()` + `orderBy()`.

### S3 - MEDIUM - No Firestore Read Budget Planning
**Description**: The architecture targets 500 concurrent users with 10,000+ products but provides no cost analysis for Firestore reads. Each home screen load could cost 10,000+ reads per user per session.
**Recommendation**: Add a caching layer with TTL (30s for products, 60s for categories). Batch product list queries. Document estimated read costs in the architecture: home screen (~80 reads), product list (~25 reads), admin dashboard (~100 reads).

### S4 - MEDIUM - Single Region Deployment
**Description**: No mention of Firestore multi-region or data residency requirements.
**Recommendation**: Document multi-region Firestore deployment (nam5 / eur3) for global scalability. Add data residency requirements to `firestore_design.md`.

---

## 2. Firestore Design Issues

### F1 - CRITICAL - isAdmin() Security Rule Logic Error
**File**: `constraints/firestore_rules.md:50-54`
**Description**: The `isAdmin()` function compares `roleId` as a hardcoded path `/roles/admin`, but `roleId` is a `DocumentReference` field pointing to a specific role document. The security rule should verify that the referenced document exists and has `name == "admin"`. The current implementation would fail if the admin role document ID is not literally "admin".
**Recommendation**: Restructure `isAdmin()` to:
```
function isAdmin() {
  return exists(/databases/$(database)/documents/roles/admin)
    && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.roleId
      == /databases/$(database)/documents/roles/admin;
}
```
Better: Denormalize `role` as a string field (`role: "admin" | "customer"`) directly on the `users` document to avoid the cross-collection read on every write operation. The `roles` collection can serve as a lookup/definition table while `users.role` stores the string value.

### F2 - HIGH - Missing Composite Indexes for Home Screen
**File**: `architecture/firestore_design.md:108-114`
**Description**: Home screen requires queries for: (1) featured + available + sorted by updatedAt, (2) active categories sorted by sortOrder, (3) active offers within date range. Only 6 composite indexes are listed but the home screen queries need additional indexes: `products` - `isFeatured` ASC, `isAvailable` ASC, `createdAt` DESC; `offers` - `isActive` ASC, `endDate` DESC.
**Recommendation**: Add the following indexes:
- `products`: `isFeatured` ASC, `isAvailable` ASC, `updatedAt` DESC
- `offers`: `isActive` ASC, `endDate` DESC
- `products`: `categoryId` ASC, `isAvailable` ASC, `price` ASC

### F3 - HIGH - No Banners Collection
**File**: `docs/requirements.md` (F1.1), `architecture/firestore_design.md`
**Description**: Requirement F1.1 specifies a banner slider on the home screen, but there is no `banners` collection in the Firestore schema. No entity, DTO, repository, or use case for banners exists.
**Recommendation**: Add a `banners` collection with fields: `id`, `titleAr`, `titleEn`, `imageUrl`, `linkUrl`, `sortOrder`, `isActive`, `createdAt`. Add entity `Banner`, DTO, repository interface/impl, and related use cases. Add CRUD to admin dashboard.

### F4 - HIGH - No Full-Text Search Strategy
**File**: `docs/requirements.md` (F3.5), `architecture/architecture.md`
**Description**: Requirement F3.5 specifies filtering and searching products by name, category, and price range. Firestore does not support native full-text search. There is no mention of Algolia, MeiliSearch, or Firebase Extensions for search.
**Recommendation**: Document full-text search strategy. Options: (A) Firebase Extensions - MeiliSearch/Algolia; (B) Cloud Firestore `array-contains` for keyword tags; (C) Client-side filtering for small datasets (<500 products). Recommend Option A for scale. Add `SearchService` to the data layer. Add `search_products_usecase.dart`.

### F5 - MEDIUM - weight_units and roles as Lookup Collections
**Description**: `weight_units` and `roles` are small lookup collections. Fetching them on every app launch without local caching wastes reads.
**Recommendation**: Cache `weight_units` and `roles` in local storage (SharedPreferences or SQLite) on first fetch. Refresh on app restart or pull-to-refresh. Add `LookupCacheService` to core layer.

### F6 - MEDIUM - offer_products Query Inefficiency
**Description**: To display products for an offer, the app must: (1) query `offer_products` where `offerId == X`, (2) for each result, fetch the product document. This is N+1 queries.
**Recommendation**: Denormalize product summary data (id, nameAr, nameEn, imageUrl, price) into the `offer_products` document or into the offer document itself as a `products` sub-collection or array. Alternatively, use a single `in` query on products collection for all associated product IDs.

### F7 - LOW - settings Collection Type Field
**File**: `architecture/firestore_design.md:92`
**Description**: The `settings` collection has a `type` field (string, number, bool). This should be enforced in security rules and handled by a deserialization strategy in the DTO layer.
**Recommendation**: Add a `SettingType` enum in the domain layer. Implement type-safe deserialization in `SettingDto`. Add Firestore security rules to validate `type` matches actual value type.

---

## 3. Localization Issues

### L1 - HIGH - Localized Firebase Exception Messages
**Description**: Firebase exceptions (auth errors, Firestore permission errors) are thrown in English by the Firebase SDK. The architecture mandates no hardcoded English text, but provides no strategy for mapping Firebase error codes to localized messages.
**Recommendation**: Add an `ErrorLocalizer` service in core/utils that maps Firebase error codes to localized ARB keys. Create ARB entries for all known Firebase errors. Add `FirebaseExceptionMapper` in data layer.

### L2 - HIGH - Localized Number/Currency Formatting
**Description**: Arabic uses different digit shapes (٠١٢٣٤٥٦٧٨٩ vs 0123456789) and currency formats. The architecture provides no strategy for locale-aware number/currency formatting.
**Recommendation**: Use `NumberFormat` from `intl` package with locale parameter for price display. Add `PriceFormatter` utility. Test with Arabic locale to ensure Eastern Arabic numerals are displayed correctly. Add ARB key for currency symbol with RTL-aware positioning.

### L3 - MEDIUM - Localized Date Formatting
**Description**: Date formatting differs significantly between Arabic and English locales (Gregorian vs Islamic calendar, different format patterns). No strategy mentioned.
**Recommendation**: Use `DateFormat` from `intl` with locale-aware patterns. Add `DateFormatter` utility to core/utils. Ensure offer date display adapts to locale.

### L4 - MEDIUM - RTL-Specific Layout Testing
**Description**: Arabic RTL layout requires testing for: mirrored navigation drawer, correct icon alignment, reversed carousel slider direction, proper text overflow in RTL, correct alignment of price+weight+direction indicators.
**Recommendation**: Add RTL testing checklist to the QA documentation. Create `Directionality`-aware layout widgets in common/widgets. Test all home screen widgets in RTL mode.

### L5 - LOW - l10n.yaml Configuration
**File**: `architecture/localization_strategy.md:67-73`
**Description**: The `synthetic-package: false` setting requires manual import path configuration. This can cause build issues if not set up correctly.
**Recommendation**: Set `synthetic-package: true` for simpler setup, or document the exact import path (`package:fresh_market/generated/l10n/app_localizations.dart`).

---

## 4. Security Issues

### A1 - CRITICAL - Inconsistent Role Authorization Strategy
**Files**: `constraints/firestore_rules.md`, `architecture/security_strategy.md`
**Description**: Two conflicting approaches are described: (1) Firebase Security Rules use `roleId` as a document reference to `roles/admin`; (2) Application-layer guards also check roles. There is no single source of truth for authorization. If security rules and app-level checks diverge, data can be exposed.
**Recommendation**: Centralize role logic: Store `role` as a string field directly on `users` document (e.g., `role: "admin"`). Security rules read `users/$(uid).data.role == "admin"`. Application still uses a `UserRole` enum. This eliminates the cross-collection read, simplifies rules, and prevents desynchronization.

### A2 - HIGH - No Firebase App Check
**Description**: No mention of Firebase App Check, leaving the API vulnerable to abuse from unauthenticated clients. Attackers could exfiltrate the entire database by calling Firestore REST endpoints directly.
**Recommendation**: Enable Firebase App Check with reCAPTCHA (web) and SafetyNet/Play Integrity (Android), DeviceCheck (iOS). Enforce in security rules: `if request.auth != null && request.token.app_check_token != null`.

### A3 - MEDIUM - Owner Verification Gap in notifications
**File**: `architecture/security_strategy.md:59-60`
**Description**: The rule allows users to read own notifications where `userId == auth.uid`. But if `userId` is stored as a `DocumentReference`, the comparison with `auth.uid` (string) will always fail.
**Recommendation**: Store `userId` as a string (the UID) in `notifications` collection, not as a `DocumentReference`. Update security rules to compare against `request.auth.uid` directly.

### A4 - MEDIUM - Overly Permissive settings Collection Read
**File**: `architecture/security_strategy.md:53-55`
**Description**: All authenticated users can read all settings. Some settings (FCM credentials, API keys) may need stricter access.
**Recommendation**: Categorize settings by sensitivity level. Public settings (store name, currency) readable by all authenticated. Private settings readable only by admin. Use subcollections or a `visibility` field enforced by security rules.

### A5 - MEDIUM - No Rate Limiting
**Description**: No rate limiting strategy for firestore writes. An attacker with stolen admin credentials could bulk-delete the entire product catalog.
**Recommendation**: Implement rate limiting via Firebase Security Rules (e.g., max 50 writes/minute per user). Consider Cloud Functions for critical operations (delete category + cascade). Add audit logging for destructive operations.

---

## 5. Performance Issues

### P1 - CRITICAL - StreamProvider Pattern Mismatch
**File**: `architecture/state_management.md:18`
**Description**: The code example shows `StreamProvider` wrapping a use case that returns `Future<List<Product>>`, not `Stream<List<Product>>`. This will not compile—`StreamProvider` requires a `Stream`, not a `Future`.
**Recommendation**: Correct the pattern: Repository returns `Stream<List<Product>>` via `Firestore.snapshots().map()`. The use case can either pass through the stream or add business logic transformations. The `StreamProvider` watches the use case's stream. Alternatively, the provider can watch the repository directly.

### P2 - HIGH - Listener-Driven Full Widget Rebuild
**Description**: The `StreamProvider` pattern causes all widgets subscribed to a stream provider to rebuild on every Firestore snapshot. A single product change triggers rebuild of the entire product list.
**Recommendation**: Use Riverpod's `select()` method to listen only to relevant state slices. For list-detail scenarios, use separate providers for list and detail views. Implement `freezed` with proper `==` equality to prevent unnecessary rebuilds.

### P3 - HIGH - No Image Optimization Strategy
**Description**: Product, category, and offer images are uploaded to Firebase Storage without any optimization strategy. Full-resolution images will cause slow load times on mobile networks.
**Recommendation**: Use Firebase Cloud Functions to generate thumbnails on upload (e.g., 200px, 400px, 800px versions). Store multiple resolution URLs in the document. Load lower resolution for list views, high resolution for detail views. Use `cached_network_image` with appropriate `memCacheWidth`/`memCacheHeight`.

### P4 - MEDIUM - No Connection State Management
**Description**: The architecture mentions offline-first but provides no strategy for handling the transition between online/offline states. Widgets subscribed to `StreamProvider` will show stale data when offline without any indicator.
**Recommendation**: Add a `ConnectivityProvider` that monitors network state. Wrap `StreamProvider` with online/offline awareness. Show offline indicator banner. Display last-synced timestamp. Queue writes and show sync status.

### P5 - LOW - No Widget-Level Loading States
**Description**: The architecture defines `CrudState` but lacks granular loading states for individual components (e.g., image loading, category section loading independently of offers section).
**Recommendation**: Decompose home screen into independently loading sections with shimmer skeletons. Each section (`BannerSlider`, `OffersSection`, `FeaturedCategories`, `FeaturedProducts`) gets its own provider with independent loading/error/empty states.

---

## 6. Missing Requirements

### M1 - HIGH - No Banner Implementation
**Requirement**: F1.1 (Banner slider)
**Issue**: No `banners` collection, entity, DTO, repository, or use case. The home screen widget `banner_slider.dart` is listed in folder structure but has no data backing.
**Recommendation**: Add full banner feature (see F3 above).

### M2 - HIGH - No Product Search Implementation
**Requirement**: F3.5 (Filter and search products by name, category, price range)
**Issue**: The `search/` feature directory exists but has no domain backing (no `search_products_usecase.dart`, no search repository). No full-text search strategy documented.
**Recommendation**: Add full search feature with use case, repository method, and search provider. Document search strategy (Algolia/MeiliSearch/Typesense).

### M3 - MEDIUM - No Cascade Delete Strategy
**Description**: When a category is deleted, its products should be handled (reassigned or disassociated). When a product is deleted, its `offer_products` entries should be cleaned up. No strategy documented.
**Recommendation**: Add Cloud Function triggers for `onDelete` events on `categories` and `products` collections. For categories: unset `categoryId` or assign to "uncategorized". For products: remove associated `offer_products` documents.

### M4 - MEDIUM - No Expired Offer Auto-Deactivation
**Description**: Offers have `endDate` but no mechanism to auto-deactivate expired offers. An expired offer would still show as active in queries that check `isActive == true`.
**Recommendation**: Add a Cloud Function scheduled trigger (e.g., daily) that sets `isActive = false` for offers where `endDate < now()`. Update active offers query to include `endDate >= now()` regardless of `isActive`.

### M5 - MEDIUM - No Admin Activity Audit Log
**Description**: No audit trail for admin actions (who created/updated/deleted a product, who changed a user's role). Required for compliance in enterprise environments.
**Recommendation**: Add an `audit_log` collection with fields: `adminId`, `action`, `targetCollection`, `targetId`, `changes`, `timestamp`. Log from Firestore security rules or Cloud Functions on every write event triggered by admin.

### M6 - LOW - No Data Export/Import
**Description**: No strategy for bulk product import (CSV/Excel) or data export. Administrators managing 10,000 products need batch operations.
**Recommendation**: Add CSV import/export use case. Cloud Function to parse CSV and batch-write to Firestore. Admin dashboard button for export (generate CSV and upload to Storage).

---

## Summary: Issues by Severity

| Severity | Count | Key Items |
|----------|-------|-----------|
| CRITICAL | 4 | Pagination, isAdmin() rule, StreamProvider pattern, Real-time listener limits |
| HIGH | 9 | Banners, Full-text search, Indexes, Role auth strategy, App Check, Number formatting, Firebase error localization, Image optimization, Listener rebuilds |
| MEDIUM | 9 | Lookup caching, offer_products N+1, RTL testing, Date formatting, Settings access, Rate limiting, Cascade delete, Expired offers, Audit log |
| LOW | 3 | synthetic-package config, settings type validation, Widget loading states |

---

## Final Recommendation

**APPROVED WITH CONDITIONS** - The architecture demonstrates sound Clean Architecture principles, proper layering, and feature-first organization. However, the following 5 items must be resolved before implementation begins:

1. **Fix `isAdmin()` security rule** - Change to string-based `role` field on `users` document or correct the reference comparison.
2. **Add pagination strategy** - Document and design cursor-based pagination for all product queries.
3. **Add `banners` collection** - Include banners in Firestore schema, entities, and repositories.
4. **Fix `StreamProvider` pattern** - Correct the architectural pattern for real-time data flow from Firestore through to Riverpod.
5. **Add full-text search strategy** - Document and include Algolia/MeiliSearch integration for product search.

Once these 5 conditions are addressed in the architecture documents, full implementation may proceed.
