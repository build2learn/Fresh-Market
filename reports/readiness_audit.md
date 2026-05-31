# Fresh Market — Readiness Audit Report

**Date:** 2026-05-31
**Scope:** Full codebase audit across 7 dimensions
**Build:** `flutter analyze` = 0 errors, 0 warnings | `flutter test` = 76/76 passed

---

## Overall Score: 6.3 / 10

> The foundation is solid — Clean Architecture adhered to, Riverpod patterns are correct, localization is functional, and all existing tests pass. However, **4 critical issues** (security rules, memory leak, missing indexes, missing pagination) block production readiness. Approximately **40 hours of remediation** before starting remaining P0 epics.

---

## 1. Architecture Consistency — Score: 7.5 / 10

**Strengths:**
- Clean Architecture strictly followed: domain → data → presentation, no reverse dependencies
- All 9 repository interfaces use consistent `abstract interface class` + `Result<T>` pattern
- All 24 use case classes follow single `call()` method convention
- Route coverage is complete for implemented features (Auth, Categories, Products)
- No circular dependencies detected

**Issues:**

| ID | Severity | Issue | File(s) |
|----|----------|-------|---------|
| A1 | HIGH | `SignOutUseCase` and `SendPasswordResetUseCase` return `Future<void>` instead of `Result<void>` | `sign_out.usecase.dart`, `send_password_reset.usecase.dart` |
| A2 | HIGH | `auth_repository_impl.getCurrentUser()` uses `await for` on a stream inside `Future` — blocks indefinitely, never closes subscription | `auth_repository_impl.dart:77-99` |
| A3 | MEDIUM | `product_detail_page.dart` bypasses use case layer — calls repository directly | `product_detail_page.dart:8-13` |
| A4 | MEDIUM | `category_form_provider.dart` creates use cases inline instead of using dedicated providers | `category_form_provider.dart:126-134` |
| A5 | LOW | 6 repository providers throw `UnimplementedError` at runtime | Providers for User, Offer, Banner, WeightUnit, Notification, Settings |
| A6 | LOW | 4 admin routes defined in `RouteConstants` but not registered in router | `/admin/offers/new`, `/admin/offers/:id`, `/admin/banners/new`, `/admin/banners/:id` |

---

## 2. Firestore Schema Quality — Score: 5.5 / 10

**Strengths:**
- Data is properly normalized (categoryId/weightUnitId as FKs, no duplicate data)
- 5/10 document types have complete `createdAt`/`updatedAt` timestamps
- FirestoreConstants used for most common field keys
- Product queries use `.limit()` and cursor pagination support

**Issues:**

| ID | Severity | Issue | File(s) |
|----|----------|-------|---------|
| F1 | **CRITICAL** | 3 composite indexes required but undocumented — queries will FAIL at runtime: (a) `products WHERE categoryId ORDER BY createdAt DESC`, (b) `products WHERE isFeatured+isAvailable ORDER BY createdAt DESC`, (c) `categories WHERE isVisible ORDER BY sortOrder` | `product_firebase_datasource.dart:49-51,86-89,116-119`, `category_firebase_datasource.dart:47-49` |
| F2 | HIGH | 5 document types missing `createdAt`/`updatedAt` timestamps: Notification, WeightUnit, Role, Setting (missing updatedAt), OfferProduct (missing updatedAt) | Corresponding entity files |
| F3 | HIGH | Category queries (`getCategories`, `getVisibleCategories`, `watchCategories`) have **NO `.limit()`** — will load all docs at once | `category_firebase_datasource.dart:30-32,47-49,64-66` |
| F4 | MEDIUM | DTO `toMap()` writes redundant `'id'` field alongside the document ID (data already in key) | `product.dto.dart:69`, `category.dto.dart:48` |
| F5 | MEDIUM | Custom `_generateId()` uses `dart:math Random()` instead of UUID v4 — collision risk | `product_repository_impl.dart`, `category_repository_impl.dart` |
| F6 | MEDIUM | `categoryId` and `imageUrl` hardcoded in datasource queries instead of using constants | `product_firebase_datasource.dart:49,189` |
| F7 | LOW | Notifications should be subcollection of `/users/{userId}/notifications/{notifId}` for proper security rule scoping | Design issue in entity/repository |

---

## 3. Flutter Best Practices — Score: 6.0 / 10

**Strengths:**
- `const` constructors used throughout
- Proper `dispose()` for controllers and stream subscriptions in most classes
- Theme system is comprehensive (M3 light + dark, all component themes)
- All existing async contexts check `mounted` before navigation
- 0 deprecation warnings

**Issues:**

| ID | Severity | Issue | File(s) |
|----|----------|-------|---------|
| BP1 | **CRITICAL** | New `TextEditingController` created on **every build** in form widgets — loses cursor/selection state | `category_form.dart:36,46`, `product_form_widget.dart:52,59,67,75,85,94` |
| BP2 | HIGH | `ProductFormState.isValid` calls `double.parse()` after `tryParse()` without null guard — will crash on invalid input | `product_form_provider.dart:44-48` |
| BP3 | HIGH | Bottom nav and admin nav labels hardcoded in English — not localizable | `app_router.dart:63-68,144-172` |
| BP4 | MEDIUM | `Image.network` used instead of `CachedNetworkImage` (package already in pubspec) | `category_form.dart:95`, `product_form_widget.dart:168`, `category_card.dart:77`, `product_card.dart:102`, `product_detail_page.dart:52` |
| BP5 | MEDIUM | Route mismatch: `_onNavTap` navigates to `/categories/list` which doesn't exist | `app_router.dart:280` |
| BP6 | MEDIUM | `AdminProductsPage` `ListView.builder` items lack `key` — widget state loss on reorder | `admin_products_page.dart:88` |
| BP7 | MEDIUM | Raw exceptions shown to users in `ProductDetailPage` and `AuthNotifier.sendPasswordReset` | `product_detail_page.dart:30`, `auth_providers.dart:148` |
| BP8 | LOW | Near-duplicate delete dialogs, image pickers, and image placeholders — should be extracted | 4 widget pairs across features |

---

## 4. Riverpod Usage — Score: 6.5 / 10

**Strengths:**
- Form providers correctly use `.family.autoDispose`
- `.watch()` vs `.read()` correctly applied (watch in build, read in callbacks)
- No `.watch()` in event handlers
- No circular provider dependencies
- All state mutations go through `state = state.copyWith()` in StateNotifiers
- Provider tree depth is manageable (5 levels)

**Issues:**

| ID | Severity | Issue | File(s) |
|----|----------|-------|---------|
| R1 | **CRITICAL** | `AuthNotifier._init()` subscribes to `watchAuthState().listen(...)` but **never cancels the StreamSubscription** — no `dispose()` override. Permanent memory leak. | `auth_providers.dart:90-101` |
| R2 | HIGH | `authStateProvider`, `isAdminProvider`, `currentUserProvider` rebuild on EVERY `AuthState` change (including `isLoading` toggles) instead of using `.select()` | `auth_providers.dart:167-177` |
| R3 | HIGH | `productListProvider` and `categoryListProvider` are NOT autoDisposed — Firestore snapshot listeners live forever even when admin pages are not visible | `product_providers.dart:52`, `category_providers.dart:35` |
| R4 | MEDIUM | `_categoryLocalDataSourceProvider` throws `UnimplementedError` if SharedPreferences not ready — should handle gracefully | `category_repository_provider.dart:22` |
| R5 | MEDIUM | 21 redundant use case providers that are thin wrappers around single repository methods — adds unnecessary indirection | All use case provider files |
| R6 | LOW | No provider/StateNotifier tests exist anywhere | `test/` directory |

---

## 5. Localization — Score: 5.0 / 10

**Strengths:**
- 226 ARB keys present in both English and Arabic (no missing translations)
- RTL/LTR handling is correct throughout (context.isRtl, hardcoded TextDirection only for bilingual text fields)
- `l10n.yaml` properly configured, `gen-l10n` output verified
- Plural rules use ICU syntax in ARB files

**Issues:**

| ID | Severity | Issue | File(s) |
|----|----------|-------|---------|
| L1 | HIGH | Zero semantic/accessibility labels anywhere — TalkBack/VoiceOver users cannot navigate | All UI files |
| L2 | HIGH | 25 hardcoded user-facing strings in UI, validators, error messages, and router nav labels | `validators.dart`, `app_router.dart:63-68,144-172`, `auth_repository_impl.dart:130-165`, etc. |
| L3 | MEDIUM | `timeAgo()` extension returns hardcoded English (`'d ago'`, `'h ago'`, etc.) | `datetime_extensions.dart:25-28` |
| L4 | MEDIUM | Profile page displays raw date (`toString().split(' ')[0]`) instead of localized format | `profile_page.dart:72-73` |
| L5 | LOW | ARB `priceFormat: "{price} SAR"` mixes English text with Arabic locale — potential BiDi issue | `app_ar.arb` |

---

## 6. Scalability — Score: 4.5 / 10

**Strengths:**
- Product queries use `.limit(20)` and cursor-based pagination API exists at datasource level
- Real-time snapshot listeners properly lifecycle-managed in admin list pages
- Category reorder uses Firestore batch writes
- Data is normalized (no duplication)

**Issues:**

| ID | Severity | Issue | File(s) |
|----|----------|-------|---------|
| S1 | HIGH | **No cursor-based pagination in UI** — `lastDoc` parameter never passed from providers, only 20 most recent products ever visible | All provider files |
| S2 | HIGH | Local cache uses `SharedPreferences` (JSON blobs) — ~6MB limit on Android; unsuitable for 10000+ products | `product_local_datasource.dart`, `category_local_datasource.dart` |
| S3 | HIGH | **No data migration strategy** — no schema version field, no migration scripts, `fromMap()` may throw on schema changes | All DTO files |
| S4 | HIGH | Cache invalidation is non-existent: `cacheDurationSeconds=30` defined but never used, mutations never clear/invalidate cache | `app_constants.dart:19-20`, all repos |
| S5 | MEDIUM | `getProduct(id)` and `getFeaturedProducts()` have NO local cache fallback | `product_repository_impl.dart:60-85` |
| S6 | MEDIUM | `watchAuthState()` triggers N+1 pattern — calls `getUserData` on every auth state change | `auth_repository_impl.dart:102-115` |
| S7 | MEDIUM | Firestore offline persistence not explicitly configured | `main.dart` |

---

## 7. Security — Score: 3.0 / 10

**Strengths:**
- Firebase SDK enforces HTTPS on all communications
- Password reset flow uses Firebase's built-in `sendPasswordResetEmail` (secure)
- No NoSQL injection vectors detected
- No hardcoded secrets beyond placeholder Firebase config keys

**Issues:**

| ID | Severity | Issue | File(s) |
|----|----------|-------|---------|
| SE1 | **CRITICAL** | **No `firestore.rules` file** — database is completely unprotected. Any authenticated user can read/write any document. | Missing file |
| SE2 | **CRITICAL** | **No `storage.rules` file** — Firebase Storage has no file type/size validation | Missing file |
| SE3 | **CRITICAL** | Role field (`isAdmin`) can be tampered — no Firestore Security Rule prevents non-admin users from setting `role: "admin"` on their own document | `user.entity.dart:23`, `auth_repository_impl.dart:52` |
| SE4 | HIGH | All `catch (e)` blocks in repositories pass `e.toString()` to failure messages — exposes Firebase internals to users | `auth_repository_impl.dart`, `product_repository_impl.dart`, `category_repository_impl.dart` |
| SE5 | HIGH | No ownership verification on user data — any authenticated user could read/write any user's document | `auth_firebase_datasource.dart:42-44,48-49` |
| SE6 | MEDIUM | Open redirect vulnerability: `redirect` query param after sign-in is not validated | `sign_in_page.dart:42-44` |
| SE7 | MEDIUM | No file type/size validation before Storage upload | `product_firebase_datasource.dart:232-238` |
| SE8 | MEDIUM | Weak password minimum (6 chars vs. recommended 8) | `validators.dart:11`, auth pages |
| SE9 | MEDIUM | No input sanitization before Firestore writes (length limits, control character stripping) | all form providers |
| SE10 | LOW | No `flutter_secure_storage` — sensitive cached data in plaintext SharedPreferences | `pubspec.yaml` |

---

## Required Fixes Before Implementing Remaining P0 Epics

### Critical (must fix before any more code)
| Priority | Area | Effort | Fix |
|----------|------|--------|-----|
| P0 | Security | 2h | Create `firestore.rules` with per-collection read/write rules, admin role guard, user data ownership |
| P0 | Security | 1h | Create `storage.rules` with file type/size validation |
| P0 | Architecture | 1h | Fix `AuthNotifier` memory leak — store and cancel `StreamSubscription` in `dispose()` |
| P0 | Firestore | 1h | Create composite indexes in Firebase Console and document in `/firestore/indexes.md` |

### High (fix before offers/banners/notifications features)
| Priority | Area | Effort | Fix |
|----------|------|--------|-----|
| P1 | Firestore | 1h | Add `.limit(100)` to all 3 category queries in `category_firebase_datasource.dart` |
| P1 | Firestore | 0.5h | Remove redundant `'id'` field from `product.dto.toMap()` and `category.dto.toMap()` |
| P1 | Flutter | 1h | Replace inline `TextEditingController()` creation with `initialValue` pattern or externally-managed controllers |
| P1 | Architecture | 1h | Fix `auth_repository_impl.getCurrentUser()` — replace `await for` with `.first` |
| P1 | Security | 2h | Map all `e.toString()` in repository catch blocks to safe, localized messages |
| P1 | Firestore | 1h | Add `createdAt`/`updatedAt` to Notification, WeightUnit, Role, Setting, OfferProduct entities |
| P1 | Localization | 2h | Extract 25 hardcoded strings to ARB files (nav labels, validators, error messages) |
| P1 | Flutter | 1h | Fix `ProductFormState.isValid` double.parse crash, fix `product_detail_page.dart` to use use case |
| P1 | Security | 1h | Add `redirect` whitelist validation in sign-in page |

### Medium (fix before customer-facing features)
| Priority | Area | Effort | Fix |
|----------|------|--------|-----|
| P2 | Riverpod | 1h | Add `.select()` to `authStateProvider`, `isAdminProvider`, `currentUserProvider` |
| P2 | Riverpod | 1h | Convert `productListProvider`/`categoryListProvider` to autoDispose |
| P2 | Firestore | 2h | Replace `_generateId()` with `uuid` package (UUID v4) |
| P2 | Firestore | 1h | Define `nameAr`, `nameEn`, `price`, `weight`, `categoryId`, `email`, etc. as FirestoreConstants |
| P2 | Localization | 2h | Add semantic/accessibility labels to all interactive elements |
| P2 | Routing | 0.5h | Fix `/categories/list` navigation to correct route |
| P2 | Routing | 0.5h | Register missing 4 admin routes in `app_router.dart` |
| P2 | Flutter | 0.5h | Add `ValueKey` to `AdminProductsPage` list items |

### Low (post-MVP polish)
| Priority | Area | Effort | Fix |
|----------|------|--------|-----|
| P3 | Testing | 4h | Add provider/StateNotifier tests for all 5 notifiers |
| P3 | Flutter | 2h | Replace `Image.network` with `CachedNetworkImage` everywhere |
| P3 | Architecture | 1h | Refactor redundant use case providers (21 thin wrappers) |
| P3 | Flutter | 1h | Extract shared widgets (delete dialog, image picker, placeholders) |
| P3 | Performance | 2h | Replace SharedPreferences cache with Hive/Isar/sqflite |
| P3 | Offline | 4h | Implement offline-first strategy: read cache first, sync background |
| P3 | Firestore | 1h | Add batch operations for bulk product CRUD |
| P3| Migration | 2h | Add schema version field + migration scripts |

---

## Summary

```
Architecture      ████████░░  7.5/10  (good foundation, 2 high-severity patterns)
Firestore Schema  █████░░░░░  5.5/10  (3 missing indexes = runtime failures)
Flutter Practices ██████░░░░  6.0/10  (1 critical anti-pattern, several medium)
Riverpod Usage    ██████░░░░  6.5/10  (1 critical leak, good patterns otherwise)
Localization      █████░░░░░  5.0/10  (zero accessibility, 25 hardcoded strings)
Scalability       ████░░░░░░  4.5/10  (no pagination in UI, SharedPreferences limit)
Security          ███░░░░░░░  3.0/10  (no rules files = completely unprotected)
────────────────────────────────────
OVERALL           ██████░░░░  6.3/10
```

**Estimated remediation: ~38-42 hours** before the codebase is production-ready.
**Estimated effort to implement remaining P0 epics (Offers, Home, Dashboard, Notifications, Settings): ~120 hours** with the current code quality level.
