# Feature Map — Fresh Market Platform

> **Legend:**  🟢 MVP  |  🟡 Phase 2  |  ⚪ Future

---

## Customer App Features

### 1. Authentication

| # | Feature | Priority | Dependencies | Effort | Notes |
|---|---------|----------|-------------|--------|-------|
| 1.1 | Sign in with email/password | 🟢 MVP | Firebase Auth | 2 days | |
| 1.2 | Sign up with email/password | 🟢 MVP | Firebase Auth | 2 days | Auto-assigns `customer` role |
| 1.3 | Sign out | 🟢 MVP | — | 0.5 day | |
| 1.4 | Persistent auth state (auto-login) | 🟢 MVP | Firebase Auth listener | 1 day | |
| 1.5 | Password reset | 🟡 Phase 2 | Firebase Auth | 1 day | |
| 1.6 | Google sign-in | ⚪ Future | Firebase Auth + Google Sign-In | 2 days | |
| 1.7 | Apple sign-in | ⚪ Future | Firebase Auth + Sign In with Apple | 2 days | iOS requirement |
| 1.8 | Biometric unlock | ⚪ Future | `local_auth` | 1.5 days | Fingerprint / Face ID |

### 2. Home Screen

| # | Feature | Priority | Dependencies | Effort | Notes |
|---|---------|----------|-------------|--------|-------|
| 2.1 | Banner slider (auto-scroll carousel) | 🟢 MVP | `banners` collection | 2 days | Real-time from Firestore |
| 2.2 | Offers section (horizontal scroll) | 🟢 MVP | `offers` + `offer_products` | 2 days | Active offers only |
| 2.3 | Featured categories grid | 🟢 MVP | `categories` collection | 1.5 days | Visible + sorted |
| 2.4 | Featured products grid | 🟢 MVP | `products` collection | 2 days | Featured + available |
| 2.5 | Pull-to-refresh | 🟢 MVP | — | 0.5 day | |
| 2.6 | Shimmer loading skeletons | 🟢 MVP | `shimmer` package | 1 day | Per-section independent loading |
| 2.7 | Offline indicator banner | 🟡 Phase 2 | `connectivity_plus` | 0.5 day | |
| 2.8 | Personalized home feed | ⚪ Future | User preferences + ML | 5 days | Based on browsing history |

### 3. Categories

| # | Feature | Priority | Dependencies | Effort | Notes |
|---|---------|----------|-------------|--------|-------|
| 3.1 | Category list (grid view) | 🟢 MVP | `categories` collection | 1.5 days | Visible only for customers |
| 3.2 | Category details (name + image) | 🟢 MVP | — | 0.5 day | Localized display |
| 3.3 | Filter products by category | 🟢 MVP | `products.categoryId` | 2 days | Paginated results |
| 3.4 | Real-time category updates | 🟢 MVP | `.snapshots()` listener | 1 day | Visibility changes reflect instantly |

### 4. Products

| # | Feature | Priority | Dependencies | Effort | Notes |
|---|---------|----------|-------------|--------|-------|
| 4.1 | Product list (grid/list toggle) | 🟢 MVP | `products` collection | 2 days | Paginated, 20 per page |
| 4.2 | Product detail page | 🟢 MVP | — | 2 days | Image, name, desc, price, weight |
| 4.3 | Product image zoom | 🟢 MVP | `photo_view` | 0.5 day | |
| 4.4 | Real-time product updates | 🟢 MVP | `.snapshots()` listener | 1 day | Price/availability changes |
| 4.5 | Sort products by price | 🟡 Phase 2 | Composite index | 1 day | ASC / DESC |
| 4.6 | Product sharing (via OS share) | 🟡 Phase 2 | `share_plus` | 0.5 day | |
| 4.7 | Recent products viewed | ⚪ Future | Local storage | 1.5 days | |

### 5. Offers

| # | Feature | Priority | Dependencies | Effort | Notes |
|---|---------|----------|-------------|--------|-------|
| 5.1 | Offer list (active offers) | 🟢 MVP | `offers` collection | 1.5 days | Filtered by date + active flag |
| 5.2 | Offer detail page | 🟢 MVP | `offer_products` + `products` | 2 days | Shows associated products |
| 5.3 | Real-time offer updates | 🟢 MVP | `.snapshots()` listener | 1 day | |
| 5.4 | Offer countdown timer | 🟡 Phase 2 | — | 0.5 day | Shows remaining time |

### 6. Search

| # | Feature | Priority | Dependencies | Effort | Notes |
|---|---------|----------|-------------|--------|-------|
| 6.1 | Search bar (global) | 🟡 Phase 2 | Algolia / MeiliSearch | 4 days | Full-text product search |
| 6.2 | Filter by category + price range | 🟡 Phase 2 | Algolia facets | 2 days | |
| 6.3 | Search suggestions | 🟡 Phase 2 | Algolia | 2 days | |
| 6.4 | Voice search | ⚪ Future | `speech_to_text` | 2 days | Arabic + English support |
| 6.5 | Scan barcode to find product | ⚪ Future | `mobile_scanner` | 2.5 days | |

### 7. Notifications

| # | Feature | Priority | Dependencies | Effort | Notes |
|---|---------|----------|-------------|--------|-------|
| 7.1 | Receive FCM push notifications | 🟢 MVP | Firebase Cloud Messaging | 2 days | Foreground + background |
| 7.2 | Handle notification tap → deep link | 🟢 MVP | GoRouter + FCM data | 1 day | Navigates to offer/product |
| 7.3 | In-app notification list | 🟡 Phase 2 | `notifications` collection | 2 days | |
| 7.4 | Mark notification as read | 🟡 Phase 2 | — | 0.5 day | |
| 7.5 | Notification preferences | ⚪ Future | `settings` collection | 1.5 days | Opt-in by type |

### 8. User Profile

| # | Feature | Priority | Dependencies | Effort | Notes |
|---|---------|----------|-------------|--------|-------|
| 8.1 | View profile | 🟡 Phase 2 | `users` collection | 1 day | |
| 8.2 | Edit profile (name, phone, photo) | 🟡 Phase 2 | Firebase Storage + `users` | 2 days | |
| 8.3 | Language switcher | 🟢 MVP | ARB + `flutter_localizations` | 1 day | Arabic / English toggle |
| 8.4 | App settings screen | 🟡 Phase 2 | — | 1 day | Language, theme, about |
| 8.5 | Theme switcher (light/dark) | 🟡 Phase 2 | `app_theme.dart` | 0.5 day | |

### 9. Cart & Checkout (Future Phases)

| # | Feature | Priority | Dependencies | Effort | Notes |
|---|---------|----------|-------------|--------|-------|
| 9.1 | Add to cart | ⚪ Future | `cart` collection | 3 days | Local + synced |
| 9.2 | Cart badge (app bar) | ⚪ Future | — | 0.5 day | |
| 9.3 | Cart list (edit quantities) | ⚪ Future | — | 2 days | |
| 9.4 | Checkout flow | ⚪ Future | Payment gateway | 5 days | |
| 9.5 | Order history | ⚪ Future | `orders` collection | 2 days | |
| 9.6 | Order tracking | ⚪ Future | — | 2 days | |

### 10. Favorites & Reviews (Future)

| # | Feature | Priority | Dependencies | Effort | Notes |
|---|---------|----------|-------------|--------|-------|
| 10.1 | Wishlist / favorites | ⚪ Future | `favorites` collection | 2 days | |
| 10.2 | Product rating (stars) | ⚪ Future | `reviews` collection | 2 days | |
| 10.3 | Product reviews (text) | ⚪ Future | — | 2 days | |

---

## Admin Dashboard Features

### 11. Authentication & Access

| # | Feature | Priority | Dependencies | Effort | Notes |
|---|---------|----------|-------------|--------|-------|
| 11.1 | Admin sign-in (same auth flow) | 🟢 MVP | Firebase Auth | reused | |
| 11.2 | Role-based route guard | 🟢 MVP | GoRouter redirect | 1 day | Non-admin → home |
| 11.3 | Admin sidebar navigation | 🟢 MVP | — | 2 days | Responsive: sidebar (web) → bottom nav (mobile) |

### 12. Product Management

| # | Feature | Priority | Dependencies | Effort | Notes |
|---|---------|----------|-------------|--------|-------|
| 12.1 | Product list (paginated, searchable) | 🟢 MVP | `products` collection | 2 days | |
| 12.2 | Add product form | 🟢 MVP | — | 3 days | All fields + validation |
| 12.3 | Edit product form | 🟢 MVP | — | 2 days | Pre-populated |
| 12.4 | Delete product | 🟢 MVP | — | 0.5 day | With confirmation |
| 12.5 | Toggle featured flag | 🟢 MVP | — | 0.5 day | Inline toggle |
| 12.6 | Toggle availability | 🟢 MVP | — | 0.5 day | Inline toggle |
| 12.7 | Upload product image | 🟢 MVP | Firebase Storage | 1 day | With progress indicator |
| 12.8 | Product image preview | 🟢 MVP | — | 0.5 day | |
| 12.9 | Bulk product import (CSV) | ⚪ Future | Cloud Function | 3 days | |
| 12.10 | Bulk product export (CSV) | ⚪ Future | Cloud Function | 2 days | |

### 13. Category Management

| # | Feature | Priority | Dependencies | Effort | Notes |
|---|---------|----------|-------------|--------|-------|
| 13.1 | Category list (sorted by sortOrder) | 🟢 MVP | `categories` collection | 1 day | |
| 13.2 | Add category form | 🟢 MVP | — | 1.5 days | Arabic + English names |
| 13.3 | Edit category form | 🟢 MVP | — | 1 day | |
| 13.4 | Upload category image | 🟢 MVP | Firebase Storage | 0.5 day | |
| 13.5 | Hide/show category toggle | 🟢 MVP | — | 0.5 day | Instant real-time effect |
| 13.6 | Drag-and-drop reorder | 🟢 MVP | `reorderable_list` | 1.5 days | Batch update sortOrder |
| 13.7 | Delete category | 🟡 Phase 2 | Cloud Function | 2 days | With cascade handling |

### 14. Offer Management

| # | Feature | Priority | Dependencies | Effort | Notes |
|---|---------|----------|-------------|--------|-------|
| 14.1 | Offer list (all offers) | 🟢 MVP | `offers` collection | 1 day | |
| 14.2 | Add offer form | 🟢 MVP | — | 2.5 days | Dates, bilingual, image |
| 14.3 | Edit offer form | 🟢 MVP | — | 2 days | |
| 14.4 | Toggle active/inactive | 🟢 MVP | — | 0.5 day | |
| 14.5 | Select associated products | 🟢 MVP | Multi-select from product list | 2 days | |
| 14.6 | Upload offer image | 🟡 Phase 2 | Firebase Storage | 0.5 day | |
| 14.7 | Send push notification on offer create | 🟡 Phase 2 | Cloud Function + FCM | 1.5 days | |
| 14.8 | Delete offer | 🟡 Phase 2 | — | 0.5 day | With cascade cleanup |
| 14.9 | Expired offer auto-deactivation | 🟡 Phase 2 | Scheduled Cloud Function | 1 day | Daily cron |

### 15. Banner Management

| # | Feature | Priority | Dependencies | Effort | Notes |
|---|---------|----------|-------------|--------|-------|
| 15.1 | Banner list | 🟢 MVP | `banners` collection | 0.5 day | |
| 15.2 | Add banner form | 🟢 MVP | — | 1.5 days | Bilingual titles, image, link |
| 15.3 | Edit banner form | 🟢 MVP | — | 1 day | |
| 15.4 | Toggle active/inactive | 🟢 MVP | — | 0.5 day | |
| 15.5 | Drag-and-drop reorder | 🟢 MVP | `reorderable_list` | 1 day | |
| 15.6 | Deep link selector | 🟡 Phase 2 | — | 1 day | Pick target screen |

### 16. User Management

| # | Feature | Priority | Dependencies | Effort | Notes |
|---|---------|----------|-------------|--------|-------|
| 16.1 | User list (paginated, searchable) | 🟢 MVP | `users` collection | 1.5 days | |
| 16.2 | View user details | 🟢 MVP | — | 0.5 day | |
| 16.3 | Change user role | 🟢 MVP | — | 0.5 day | customer ↔ admin |
| 16.4 | Deactivate user account | 🟡 Phase 2 | — | 0.5 day | |
| 16.5 | View user notification history | ⚪ Future | `notifications` collection | 1 day | |

### 17. Settings & Configuration

| # | Feature | Priority | Dependencies | Effort | Notes |
|---|---------|----------|-------------|--------|-------|
| 17.1 | Settings list (key-value editor) | 🟢 MVP | `settings` collection | 1.5 days | |
| 17.2 | Edit string/number/bool settings | 🟢 MVP | — | 1 day | Typed input fields |
| 17.3 | Weight units management | 🟢 MVP | `weight_units` collection | 1 day | CRUD lookup table |
| 17.4 | Role management | 🟡 Phase 2 | `roles` collection | 1 day | Edit permissions |
| 17.5 | Audit log viewer | ⚪ Future | `audit_log` collection | 2 days | |

### 18. Dashboard & Analytics

| # | Feature | Priority | Dependencies | Effort | Notes |
|---|---------|----------|-------------|--------|-------|
| 18.1 | Admin dashboard home with stats | 🟡 Phase 2 | Aggregation queries | 2 days | Product count, user count |
| 18.2 | Recent activity feed | ⚪ Future | `audit_log` collection | 2 days | |
| 18.3 | Sales analytics charts | ⚪ Future | `orders` + cloud functions | 5 days | |
| 18.4 | Product performance report | ⚪ Future | — | 3 days | Most viewed, top sellers |

---

## Shared / Cross-Cutting Features

### 19. Architecture & Infrastructure

| # | Feature | Priority | Dependencies | Effort | Notes |
|---|---------|----------|-------------|--------|-------|
| 19.1 | Clean Architecture scaffolding | 🟢 MVP | — | 3 days | Domain / Data / Presentation layers |
| 19.2 | Riverpod DI setup | 🟢 MVP | `flutter_riverpod` | 1 day | Provider overrides for testing |
| 19.3 | GoRouter navigation | 🟢 MVP | `go_router` | 2 days | ShellRoute, guards |
| 19.4 | Firebase initialization | 🟢 MVP | `firebase_core` | 1 day | Per-platform config |
| 19.5 | Error handling & retry | 🟢 MVP | `app_exception.dart` | 1 day | Typed exceptions + localized messages |
| 19.6 | Logging (structured) | 🟡 Phase 2 | `logger` | 1 day | Debug, info, error levels |

### 20. Localization

| # | Feature | Priority | Dependencies | Effort | Notes |
|---|---------|----------|-------------|--------|-------|
| 20.1 | ARB file setup (ar + en) | 🟢 MVP | `flutter_localizations` | 1 day | Complete all MVP keys |
| 20.2 | RTL layout support | 🟢 MVP | Material 3 | 1 day | Auto-mirroring, Directionality |
| 20.3 | Language switcher (in-app) | 🟢 MVP | Provider + locale rebuild | 1 day | Persists preference |
| 20.4 | Localized numbers / currency | 🟢 MVP | `intl` NumberFormat | 0.5 day | Eastern Arabic numerals |
| 20.5 | Localized dates | 🟢 MVP | `intl` DateFormat | 0.5 day | |
| 20.6 | Firebase error → localized message | 🟡 Phase 2 | `ErrorLocalizer` | 1 day | Maps error codes to ARB keys |
| 20.7 | Plural support (ARB) | 🟡 Phase 2 | ARB `{count, plural}` | 0.5 day | |

### 21. Real-Time Synchronization

| # | Feature | Priority | Dependencies | Effort | Notes |
|---|---------|----------|-------------|--------|-------|
| 21.1 | Firestore snapshot listeners | 🟢 MVP | `cloud_firestore` | 2 days | Products, categories, offers |
| 21.2 | StreamProvider for reactive UI | 🟢 MVP | Riverpod | 1 day | |
| 21.3 | Optimistic UI updates | 🟡 Phase 2 | — | 2 days | Update UI before server confirms |
| 21.4 | Conflict resolution (last-write-wins) | 🟡 Phase 2 | Firestore built-in | 0.5 day | |

### 22. Offline-First

| # | Feature | Priority | Dependencies | Effort | Notes |
|---|---------|----------|-------------|--------|-------|
| 22.1 | Firestore offline persistence | 🟢 MVP | `settings(persistenceEnabled: true)` | 0.5 day | Built-in Firestore caching |
| 22.2 | Connectivity monitoring | 🟢 MVP | `connectivity_plus` | 0.5 day | |
| 22.3 | Offline banner UI | 🟡 Phase 2 | — | 0.5 day | |
| 22.4 | Queue writes when offline | ⚪ Future | Firestore built-in | — | Auto-sync when online |

### 23. Security

| # | Feature | Priority | Dependencies | Effort | Notes |
|---|---------|----------|-------------|--------|-------|
| 23.1 | Firebase Security Rules | 🟢 MVP | Firebase Console | 2 days | Full rules deployment |
| 23.2 | Admin route guard | 🟢 MVP | GoRouter redirect | 1 day | |
| 23.3 | Firebase App Check | 🟡 Phase 2 | reCAPTCHA / SafetyNet | 1 day | API abuse prevention |
| 23.4 | Rate limiting (security rules) | 🟡 Phase 2 | Firestore rules | 1 day | Max writes per minute |
| 23.5 | Admin activity audit log | ⚪ Future | `audit_log` collection | 2 days | Cloud Function trigger |

### 24. UI / UX

| # | Feature | Priority | Dependencies | Effort | Notes |
|---|---------|----------|-------------|--------|-------|
| 24.1 | Responsive layout (mobile + web) | 🟢 MVP | `LayoutBuilder`, `breakpoints` | 3 days | |
| 24.2 | Loading states (shimmer) | 🟢 MVP | `shimmer` package | 1 day | |
| 24.3 | Error states (retry widget) | 🟢 MVP | — | 0.5 day | |
| 24.4 | Empty states | 🟢 MVP | — | 0.5 day | "No products" illustration |
| 24.5 | Custom app theme (colors, typography) | 🟢 MVP | — | 1 day | |
| 24.6 | Snackbar notifications | 🟢 MVP | ScaffoldMessenger | 0.5 day | Success / error feedback |
| 24.7 | Dark mode support | 🟡 Phase 2 | — | 1 day | |
| 24.8 | Animations (page transitions) | 🟡 Phase 2 | GoRouter custom transitions | 1 day | |

### 25. Testing & Quality

| # | Feature | Priority | Dependencies | Effort | Notes |
|---|---------|----------|-------------|--------|-------|
| 25.1 | Unit tests: use cases | 🟢 MVP | `mocktail` | 3 days | All MVP use cases |
| 25.2 | Unit tests: entities | 🟢 MVP | — | 1 day | Equality, copyWith |
| 25.3 | Unit tests: DTO serialization | 🟢 MVP | `json_serializable` | 2 days | Round-trip tests |
| 25.4 | Unit tests: repositories (mocked) | 🟡 Phase 2 | Mock Firebase | 3 days | |
| 25.5 | Widget tests: all pages | 🟡 Phase 2 | `flutter_test` | 4 days | |
| 25.6 | Integration tests: auth flow | 🟡 Phase 2 | `integration_test` | 2 days | |
| 25.7 | Integration tests: CRUD flows | ⚪ Future | Firestore emulator | 4 days | |
| 25.8 | E2E tests: full user journey | ⚪ Future | Patrol / Detox | 5 days | |

### 26. DevOps & Deployment

| # | Feature | Priority | Dependencies | Effort | Notes |
|---|---------|----------|-------------|--------|-------|
| 26.1 | Firebase project setup | 🟢 MVP | Firebase Console | 1 day | Auth, Firestore, Storage |
| 26.2 | Android build config | 🟢 MVP | google-services.json | 0.5 day | |
| 26.3 | iOS build config | 🟢 MVP | GoogleService-Info.plist | 0.5 day | |
| 26.4 | Web build config | 🟢 MVP | firebase-config.js | 0.5 day | |
| 26.5 | Firebase Security Rules deploy | 🟢 MVP | Firebase CLI | 0.5 day | |
| 26.6 | Firestore composite indexes deploy | 🟢 MVP | `firestore.indexes.json` | 0.5 day | |
| 26.7 | Firebase Cloud Functions (cascade delete) | 🟡 Phase 2 | Firebase CLI + Cloud Functions | 2 days | |
| 26.8 | Scheduled Cloud Function (expired offers) | 🟡 Phase 2 | Cloud Scheduler | 1 day | |
| 26.9 | CI/CD pipeline (GitHub Actions) | ⚪ Future | Firebase App Distribution | 2 days | |
| 26.10 | Web hosting (Firebase Hosting) | ⚪ Future | Firebase CLI | 0.5 day | |
| 26.11 | Monitoring (Crashlytics + Performance) | 🟡 Phase 2 | Firebase Monitoring | 1 day | |

---

## Summary Counts

| Category | 🟢 MVP | 🟡 Phase 2 | ⚪ Future | Total |
|----------|--------|------------|-----------|-------|
| Customer App | 23 | 13 | 10 | 46 |
| Admin Dashboard | 23 | 8 | 6 | 37 |
| Shared / Cross-Cutting | 22 | 15 | 5 | 42 |
| **Total** | **68** | **36** | **21** | **125** |

## MVP Effort Estimate

| Layer | Estimated Days |
|-------|---------------|
| Customer App features | 38 days |
| Admin Dashboard features | 28 days |
| Shared / Cross-cutting features | 25 days |
| **Total MVP** | **~91 days (3-4 devs, ~8 weeks)** |

## Key Dependencies for MVP

```
Authentication (Firebase Auth)
  └── User role check
       ├── Admin Dashboard (all features require admin role)
       └── Customer App (all features require authenticated customer)
            ├── Home Screen (requires products, categories, offers, banners)
            ├── Category List (requires categories collection)
            ├── Product List (requires products collection)
            └── Offer List (requires offers + offer_products)
```

## Feature Gating Strategy

- **MVP features**: Must-have for launch. Core catalog browsing, admin CRUD.
- **Phase 2**: Enhances UX. Search, profile, push notifications, offline improvements.
- **Future**: Commerce enablement. Cart, checkout, orders, analytics.

All shared infrastructure (Clean Architecture, Riverpod, Firebase, localization, security rules, responsive layout) is included in MVP because every feature depends on it.
