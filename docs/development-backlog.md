# Development Backlog

> **Priorities:** P0 = Critical (MVP) · P1 = Important (Phase 2) · P2 = Nice to have (Future)
> **Effort:** hours (h) · days (d) · points (SP)

---

## EPIC 1: Project Setup & Infrastructure

**Goal:** Initialize Flutter project, dependencies, Firebase, and core architecture scaffolding.
**Priority:** P0
**Total Effort:** 34h

### Story 1.1 — Flutter Project Initialization
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P0 | Create Flutter project with Android/iOS/Web platforms | 1h | — |
| P0 | Configure `pubspec.yaml` with all dependencies | 1h | 1.1.1 |
| P0 | Set up `analysis_options.yaml` with strict linting | 0.5h | 1.1.1 |
| P0 | Create folder structure (core/domain/data/presentation) | 1h | 1.1.1 |
| P0 | Configure `l10n.yaml` for ARB localization | 0.5h | 1.1.1 |

### Story 1.2 — Firebase Project Setup
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P0 | Create Firebase project (console) | 1h | — |
| P0 | Register Android app + download `google-services.json` | 0.5h | 1.2.1 |
| P0 | Register iOS app + download `GoogleService-Info.plist` | 0.5h | 1.2.1 |
| P0 | Register Web app + configure `firebase-config.js` | 0.5h | 1.2.1 |
| P0 | Enable Authentication (email/password) in console | 0.5h | 1.2.1 |
| P0 | Create Firestore database in production mode | 0.5h | 1.2.1 |
| P0 | Enable Firebase Storage | 0.5h | 1.2.1 |
| P0 | Enable Firebase Cloud Messaging | 0.5h | 1.2.1 |
| P0 | Initialize Firebase in `main.dart` with `Firebase.initializeApp()` | 1h | 1.2.2-1.2.5 |

### Story 1.3 — Core Architecture Scaffolding
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P0 | Create `Result<T>` / Either pattern in `core/utils` | 1h | 1.1.4 |
| P0 | Create enums: `UserRole`, `RequestState`, `NotificationType` | 0.5h | 1.1.4 |
| P0 | Create base exceptions: `AppException`, `AuthException`, `FirestoreException` | 1h | 1.1.4 |
| P0 | Create `FirestoreConstants` with all collection paths | 0.5h | 1.2.6 |
| P0 | Create `RouteConstants` with all route path strings | 0.5h | 1.1.4 |
| P0 | Create `AppConstants` (page sizes, timeouts) | 0.5h | 1.1.4 |
| P0 | Create `ConnectivityService` for network monitoring | 1h | 1.1.4 |
| P0 | Create core Riverpod providers: `FirebaseProviders`, `ConnectivityProvider`, `LocaleProvider` | 1h | 1.2.9, 1.3.3 |
| P0 | Create `LoggerService` wrapper | 0.5h | 1.1.4 |

### Story 1.4 — Theme & Design System
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P0 | Create color palette (`AppColors`) with brand + semantic tokens | 1h | 1.1.1 |
| P0 | Create typography (`AppTypography`) with Cairo + Poppins fonts | 1h | 1.1.1, asset fonts |
| P0 | Create spacing/dimensions (`AppDimensions`) | 0.5h | 1.1.1 |
| P0 | Create light + dark theme (`AppTheme`) with M3 `ColorScheme` | 2h | 1.4.1-1.4.3 |
| P0 | Set up `app.dart` with `MaterialApp.router`, theme, locale | 1h | 1.4.4 |

### Story 1.5 — Routing & Navigation
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P0 | Create GoRouter instance with all routes | 2h | 1.4.5 |
| P0 | Create `AuthGuard` redirect logic | 1h | 1.5.1 |
| P0 | Create `AdminGuard` role-check redirect | 0.5h | 1.5.1 |
| P0 | Create customer `ShellRoute` with bottom navigation bar | 2h | 1.5.1 |
| P0 | Create admin `ShellRoute` with sidebar | 2h | 1.5.1 |

### Story 1.6 — Firestore Security Rules & Indexes
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P0 | Write `firestore.rules` with all collection rules + validation functions | 3h | 1.2.6 |
| P0 | Create `firestore.indexes.json` with all 11 composite indexes | 1h | 1.2.6 |
| P0 | Deploy rules + indexes via Firebase CLI | 0.5h | 1.6.1, 1.6.2 |
| P0 | Write Firebase Storage security rules | 0.5h | 1.6.3 |

### Story 1.7 — Seed Data Script
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P0 | Create seed script for `roles` collection (admin + customer) | 0.5h | 1.2.6 |
| P0 | Create seed script for `weight_units` (kg, g, lb) | 0.5h | 1.2.6 |
| P0 | Create admin user seed (for development) | 0.5h | 1.2.5, 1.7.1 |
| P0 | Run seed scripts via `dart run` | 0.5h | 1.7.1-1.7.3 |

---

## EPIC 2: Authentication & Authorization

**Goal:** Full auth flow with email/password, persistent sessions, role-based guards.
**Priority:** P0
**Total Effort:** 24h

### Story 2.1 — Auth Domain Layer
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P0 | Create `User` entity (immutable, freezed) | 1h | 1.1.4 |
| P0 | Create `AuthRepository` interface (signIn, signUp, signOut, watchAuth, getCurrentUser) | 1h | 2.1.1 |
| P0 | Create `SignInUseCase` | 0.5h | 2.1.2 |
| P0 | Create `SignUpUseCase` | 0.5h | 2.1.2 |
| P0 | Create `SignOutUseCase` | 0.5h | 2.1.2 |
| P0 | Create `GetCurrentUserUseCase` | 0.5h | 2.1.2 |
| P0 | Create `WatchAuthStateUseCase` | 0.5h | 2.1.2 |

### Story 2.2 — Auth Data Layer
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P0 | Create `UserDto` with JSON serialization | 0.5h | 2.1.1 |
| P0 | Create `UserModel` with `toEntity()`/`fromEntity()` | 0.5h | 2.2.1 |
| P0 | Create `AuthFirebaseDataSource` (Firebase Auth calls) | 2h | 1.2.9 |
| P0 | Create `AuthLocalDataSource` (secure token storage) | 1h | 1.2.9 |
| P0 | Create `AuthRepositoryImpl` | 2h | 2.2.3, 2.2.4 |
| P0 | Create `AuthRepositoryProvider` (Riverpod DI) | 0.5h | 2.2.5 |

### Story 2.3 — Auth Presentation Layer
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P0 | Create `AuthState` (freezed: unauthenticated, authenticated, loading, error) | 0.5h | 2.1.3-2.1.6 |
| P0 | Create `AuthStateProvider` (watches auth stream) | 1h | 2.2.6 |
| P0 | Create `AuthFormProvider` (sign-in/sign-up form state) | 1h | 2.2.6 |
| P0 | Create `SignInPage` with form UI | 2h | 2.3.2, 2.3.3 |
| P0 | Create `SignUpPage` with form UI | 2h | 2.3.2, 2.3.3 |
| P0 | Create `SignInForm` widget (email + password fields, validation, submit) | 1h | 2.3.3 |
| P0 | Create `SignUpForm` widget | 1h | 2.3.3 |
| P0 | Create `ForgotPasswordPage` | 1h | 2.3.2 |
| P0 | Wire auth routes into GoRouter + AuthGuard | 1h | 1.5.2, 2.3.2 |

### Story 2.4 — Auth Tests
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P0 | Unit test: `SignInUseCase` | 1h | 2.1.3 |
| P0 | Unit test: `SignUpUseCase` | 1h | 2.1.4 |
| P0 | Unit test: `SignOutUseCase` | 0.5h | 2.1.5 |
| P0 | Unit test: `AuthRepositoryImpl` with mocked Firebase | 2h | 2.2.5 |
| P0 | Widget test: `SignInPage` | 1h | 2.3.4 |

---

## EPIC 3: Category Management

**Goal:** Full CRUD for categories with bilingual names, images, visibility toggles, and drag-and-drop reorder.
**Priority:** P0
**Total Effort:** 30h

### Story 3.1 — Category Entity & DTO
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P0 | Create `Category` entity (freezed, immutable) | 0.5h | 1.1.4 |
| P0 | Create `CategoryDto` (JSON serialization) | 0.5h | 3.1.1 |
| P0 | Create `CategoryModel` (toEntity/fromEntity) | 0.5h | 3.1.2 |

### Story 3.2 — Category Repository & Data Sources
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P0 | Create `CategoryRepository` interface | 0.5h | 3.1.1 |
| P0 | Create `CategoryFirebaseDataSource` (CRUD + snapshots + reorder batch) | 3h | 1.2.6, 3.1.3 |
| P0 | Create `CategoryLocalDataSource` (offline cache) | 1h | 3.2.1 |
| P0 | Create `CategoryRepositoryImpl` | 2h | 3.2.2, 3.2.3 |
| P0 | Create `CategoryRepositoryProvider` | 0.5h | 3.2.4 |

### Story 3.3 — Category Use Cases
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P0 | Create `GetCategoriesUseCase` | 0.5h | 3.2.1 |
| P0 | Create `GetVisibleCategoriesUseCase` | 0.5h | 3.2.1 |
| P0 | Create `WatchCategoriesUseCase` (real-time stream) | 0.5h | 3.2.1 |
| P0 | Create `CreateCategoryUseCase` | 0.5h | 3.2.1 |
| P0 | Create `UpdateCategoryUseCase` | 0.5h | 3.2.1 |
| P0 | Create `ToggleCategoryVisibilityUseCase` | 0.5h | 3.2.1 |
| P0 | Create `ReorderCategoriesUseCase` | 0.5h | 3.2.1 |

### Story 3.4 — Category Admin UI
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P0 | Create `AdminCategoriesProvider` | 1h | 3.3.1-3.3.7 |
| P0 | Create `AdminCategoriesPage` (sortable list, visibility toggles) | 3h | 3.4.1 |
| P0 | Create `AdminCategoryFormPage` (add/edit form) | 3h | 3.4.1 |
| P0 | Create `CategoryListTile` widget (drag handle, image, names, actions) | 1h | 3.4.2 |
| P0 | Create `CategoryForm` widget (image uploader, bilingual fields, visibility toggle) | 2h | 3.4.3 |
| P0 | Create `ReorderCategoriesUseCase` + batch update integration | 2h | 3.4.2 |

### Story 3.5 — Category Customer UI
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P0 | Create `CategoryCard` widget (image circle + name) | 1h | 3.1.1 |
| P0 | Integrate featured categories into home screen grid | 1h | 3.5.1, home screen |
| P0 | Create `CategoryProductsPage` (header + product grid) | 2h | 3.2.5 |

### Story 3.6 — Category Tests
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P0 | Unit test: `Category` entity equality | 0.5h | 3.1.1 |
| P0 | Unit test: `CategoryDto` round-trip serialization | 0.5h | 3.1.2 |
| P0 | Unit test: `CreateCategoryUseCase` | 1h | 3.3.4 |
| P0 | Unit test: `ToggleCategoryVisibilityUseCase` | 1h | 3.3.6 |
| P0 | Unit test: `ReorderCategoriesUseCase` | 1h | 3.3.7 |
| P0 | Unit test: `CategoryRepositoryImpl` | 2h | 3.2.4 |

---

## EPIC 4: Product Management

**Goal:** Full CRUD for products with bilingual content, images, categorization, featured/availability toggles, and pagination.
**Priority:** P0
**Total Effort:** 44h

### Story 4.1 — Product Entity & DTO
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P0 | Create `Product` entity (freezed, 14 fields) | 1h | 1.1.4 |
| P0 | Create `ProductDto` (JSON serialization, all fields) | 1h | 4.1.1 |
| P0 | Create `ProductModel` (toEntity/fromEntity, Firestore mapping) | 1h | 4.1.2 |
| P0 | Create `PaginatedResult<T>` wrapper | 0.5h | 4.1.1 |

### Story 4.2 — Product Repository & Data Sources
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P0 | Create `ProductRepository` interface (CRUD + streams + paginated queries) | 1h | 4.1.1 |
| P0 | Create `ProductFirebaseDataSource` (CRUD, snapshots, paginated queries, image upload) | 4h | 1.2.6, 4.1.3 |
| P0 | Create `ProductLocalDataSource` (offline cache for product lists) | 1.5h | 4.2.1 |
| P0 | Create `ProductRepositoryImpl` | 3h | 4.2.2, 4.2.3 |
| P0 | Create `ProductRepositoryProvider` | 0.5h | 4.2.4 |

### Story 4.3 — Product Use Cases
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P0 | Create `GetProductsUseCase` (paginated) | 0.5h | 4.2.1 |
| P0 | Create `GetProductUseCase` (by ID) | 0.5h | 4.2.1 |
| P0 | Create `GetFeaturedProductsUseCase` | 0.5h | 4.2.1 |
| P0 | Create `GetProductsByCategoryUseCase` | 0.5h | 4.2.1 |
| P0 | Create `WatchProductsUseCase` (real-time) | 0.5h | 4.2.1 |
| P0 | Create `CreateProductUseCase` | 0.5h | 4.2.1 |
| P0 | Create `UpdateProductUseCase` | 0.5h | 4.2.1 |
| P0 | Create `DeleteProductUseCase` | 0.5h | 4.2.1 |
| P0 | Create `ToggleFeaturedUseCase` | 0.5h | 4.2.1 |
| P0 | Create `ToggleAvailabilityUseCase` | 0.5h | 4.2.1 |

### Story 4.4 — Product Admin UI
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P0 | Create `AdminProductsProvider` | 1.5h | 4.3.1-4.3.10 |
| P0 | Create `AdminProductsPage` (data table, search, filters, pagination) | 4h | 4.4.1 |
| P0 | Create `AdminProductFormPage` (add/edit form) | 4h | 4.4.1 |
| P0 | Create `AdminProductFormProvider` (form state + validation) | 2h | 4.4.3 |
| P0 | Create `ProductListTile` (image, name, price, status chips, action buttons) | 1.5h | 4.4.2 |
| P0 | Create `AdminImageUploader` widget (pick, preview, crop, upload to Storage) | 2h | 4.4.3 |
| P0 | Create inline featured/availability toggle in list | 1h | 4.4.2 |
| P0 | Create delete confirmation dialog | 0.5h | 4.4.2 |

### Story 4.5 — Product Customer UI
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P0 | Create `ProductCard` widget (image, bilingual name, price, weight, badge) | 2h | 4.1.1 |
| P0 | Create `ProductGrid` (responsive: 2 cols mobile, 5 cols desktop) | 1.5h | 4.5.1 |
| P0 | Create `ProductDetailPage` (image zoom, all fields, category link, offers) | 3h | 4.3.2 |
| P0 | Create `ProductDetailProvider` | 1h | 4.5.3 |
| P0 | Integrate featured products into home screen | 1h | 4.5.1 |
| P0 | Create `ProductListPage` (all products, paginated, sorted) | 2h | 4.5.1 |
| P0 | Create `ProductListProvider` | 1h | 4.5.6 |

### Story 4.6 — Product Tests
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P0 | Unit test: `Product` entity equality + copyWith | 0.5h | 4.1.1 |
| P0 | Unit test: `ProductDto` round-trip JSON | 1h | 4.1.2 |
| P0 | Unit test: `CreateProductUseCase` | 1h | 4.3.6 |
| P0 | Unit test: `GetProductsUseCase` (paginated) | 1h | 4.3.1 |
| P0 | Unit test: `ProductRepositoryImpl` with mocked Firestore | 2h | 4.2.4 |
| P0 | Widget test: `ProductCard` | 0.5h | 4.5.1 |
| P0 | Widget test: `ProductDetailPage` | 1h | 4.5.3 |

---

## EPIC 5: Offer Management

**Goal:** Full CRUD for offers with bilingual content, images, date validity, product associations, and active/inactive toggles.
**Priority:** P0
**Total Effort:** 34h

### Story 5.1 — Offer Entities & DTOs
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P0 | Create `Offer` entity (freezed) | 0.5h | 1.1.4 |
| P0 | Create `OfferProduct` entity (junction) | 0.5h | 1.1.4 |
| P0 | Create `OfferDto` | 0.5h | 5.1.1 |
| P0 | Create `OfferProductDto` | 0.5h | 5.1.2 |
| P0 | Create `OfferModel` | 0.5h | 5.1.3 |
| P0 | Create `OfferProductModel` | 0.5h | 5.1.4 |

### Story 5.2 — Offer Repository & Data Sources
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P0 | Create `OfferRepository` interface | 0.5h | 5.1.1 |
| P0 | Create `OfferFirebaseDataSource` (CRUD + offer_products join + snapshots) | 3h | 1.2.6, 5.1.5, 5.1.6 |
| P0 | Create `OfferRepositoryImpl` | 2h | 5.2.2 |
| P0 | Create `OfferRepositoryProvider` | 0.5h | 5.2.3 |

### Story 5.3 — Offer Use Cases
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P0 | Create `GetOffersUseCase` | 0.5h | 5.2.1 |
| P0 | Create `GetActiveOffersUseCase` | 0.5h | 5.2.1 |
| P0 | Create `GetOfferUseCase` (with associated products) | 0.5h | 5.2.1 |
| P0 | Create `WatchActiveOffersUseCase` | 0.5h | 5.2.1 |
| P0 | Create `CreateOfferUseCase` (with product associations) | 1h | 5.2.1 |
| P0 | Create `UpdateOfferUseCase` | 0.5h | 5.2.1 |
| P0 | Create `ToggleOfferActiveUseCase` | 0.5h | 5.2.1 |

### Story 5.4 — Offer Admin UI
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P0 | Create `AdminOffersProvider` | 1h | 5.3.1-5.3.7 |
| P0 | Create `AdminOffersPage` (data table, status chips, inline toggle) | 3h | 5.4.1 |
| P0 | Create `AdminOfferFormPage` (add/edit form) | 3h | 5.4.1 |
| P0 | Create `ProductSelectorDialog` (multi-select from product list) | 3h | 5.4.3 |

### Story 5.5 — Offer Customer UI
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P0 | Create `OfferCard` widget (image 16:9, bilingual title, countdown) | 1.5h | 5.1.1 |
| P0 | Create `OfferListPage` (active offers, paginated) | 2h | 5.3.2 |
| P0 | Create `OfferDetailPage` (image, title, description, countdown, product grid) | 3h | 5.3.3 |
| P0 | Create `OfferCountdownTimer` widget | 1h | 5.5.3 |
| P0 | Integrate offers section into home screen | 1h | 5.5.1 |

### Story 5.6 — Offer Tests
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P0 | Unit test: `Offer` entity | 0.5h | 5.1.1 |
| P0 | Unit test: `CreateOfferUseCase` (with product associations) | 1.5h | 5.3.5 |
| P0 | Unit test: `GetActiveOffersUseCase` | 1h | 5.3.2 |
| P0 | Unit test: `OfferRepositoryImpl` | 2h | 5.2.3 |

---

## EPIC 6: Banner Management

**Goal:** CRUD for home screen banners with bilingual titles, images, deep links, active toggles, and reorder.
**Priority:** P0
**Total Effort:** 18h

### Story 6.1 — Banner Entity & DTO
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P0 | Create `Banner` entity | 0.5h | 1.1.4 |
| P0 | Create `BannerDto` | 0.5h | 6.1.1 |
| P0 | Create `BannerModel` | 0.5h | 6.1.2 |

### Story 6.2 — Banner Repository & Use Cases
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P0 | Create `BannerRepository` interface | 0.5h | 6.1.1 |
| P0 | Create `BannerFirebaseDataSource` | 1.5h | 1.2.6 |
| P0 | Create `BannerRepositoryImpl` | 1h | 6.2.2 |
| P0 | Create `GetActiveBannersUseCase` | 0.5h | 6.2.1 |
| P0 | Create `WatchBannersUseCase` | 0.5h | 6.2.1 |
| P0 | Create `CreateBannerUseCase` | 0.5h | 6.2.1 |
| P0 | Create `UpdateBannerUseCase` | 0.5h | 6.2.1 |
| P0 | Create `ReorderBannersUseCase` | 0.5h | 6.2.1 |
| P0 | Create `BannerRepositoryProvider` | 0.5h | 6.2.3 |

### Story 6.3 — Banner UI
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P0 | Create `BannerCarousel` widget (auto-scroll, RTL-aware, dot indicators) | 2h | 6.1.1 |
| P0 | Integrate carousel into home screen | 0.5h | 6.3.1 |
| P0 | Create admin banner list page | 1.5h | 6.2.7 |
| P0 | Create admin banner form page | 1.5h | 6.2.7 |
| P0 | Add banner deep link tap handler | 1h | 6.3.1 |

---

## EPIC 7: Home Screen

**Goal:** Build the main customer landing page with 4 independently-loading sections.
**Priority:** P0
**Total Effort:** 20h

### Story 7.1 — Home Screen Provider
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P0 | Create `HomeProvider` (composed state from all 4 sections) | 2h | 4.5.2, 3.3.3, 5.3.4, 6.2.4 |
| P0 | Create `BannersProvider` (wraps watch banners use case) | 0.5h | 6.2.4 |
| P0 | Create `HomeOffersProvider` (wraps watch active offers) | 0.5h | 5.3.4 |
| P0 | Create `HomeCategoriesProvider` (wraps watch visible categories) | 0.5h | 3.3.3 |
| P0 | Create `FeaturedProductsProvider` (wraps watch featured products) | 0.5h | 4.3.3 |

### Story 7.2 — Home Screen Widgets
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P0 | Create `BannersSection` (BannerCarousel) | 1h | 6.3.1 |
| P0 | Create `OffersSection` (horizontal scroll + "See All" link) | 2h | 5.5.1 |
| P0 | Create `FeaturedCategoriesSection` (grid, 4-6 cols) | 1.5h | 3.5.2 |
| P0 | Create `FeaturedProductsSection` (grid + "View All" link) | 1.5h | 4.5.2 |
| P0 | Create `SectionHeader` widget (title + action link) | 0.5h | 7.2.1-7.2.4 |
| P0 | Create `HomeShimmer` loading skeleton | 1h | 7.2.1-7.2.4 |
| P0 | Create `HomePage` composing all sections with pull-to-refresh | 2h | 7.2.1-7.2.6 |
| P0 | Create `HomeProvider` for composed state management | 2h | 7.2.7 |
| P0 | Handle empty/hidden sections (no empty states — hide entirely) | 0.5h | 7.2.7 |

### Story 7.3 — Common Widgets
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P0 | Create `ResponsiveBuilder` (breakpoint-based layout switching) | 1h | — |
| P0 | Create `ShimmerLoading` (reusable skeleton component) | 1h | — |
| P0 | Create `AppImage` (cached network image with placeholder) | 0.5h | — |
| P0 | Create `ErrorWidget` (error state with retry button) | 0.5h | — |
| P0 | Create `EmptyStateWidget` | 0.5h | — |
| P0 | Create `PaginatedGrid` / `PaginatedList` | 2h | — |
| P0 | Create `ConfirmDialog` | 0.5h | — |

---

## EPIC 8: Search

**Goal:** Product search with Algolia integration, filters, and suggestions.
**Priority:** P1 (Phase 2)
**Total Effort:** 24h

### Story 8.1 — Search Infrastructure
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P1 | Set up Algolia account + create index | 1h | — |
| P1 | Install and configure `algolia` Firebase Extension (firestore-sync) | 2h | 1.2.6 |
| P1 | Configure Algolia index settings (searchableAttributes, facets) | 1h | 8.1.1 |
| P1 | Add `algolia_client` package to pubspec.yaml | 0.5h | 8.1.1 |

### Story 8.2 — Search Domain Layer
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P1 | Create `SearchRepository` interface | 0.5h | — |
| P1 | Create `SearchProductsUseCase` | 0.5h | 8.2.1 |
| P1 | Create `GetSearchSuggestionsUseCase` | 0.5h | 8.2.1 |

### Story 8.3 — Search Data Layer
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P1 | Create `AlgoliaSearchDataSource` (Algolia SDK integration) | 3h | 8.1.4 |
| P1 | Create `SearchRepositoryImpl` | 1.5h | 8.3.1 |
| P1 | Create `SearchRepositoryProvider` | 0.5h | 8.3.2 |

### Story 8.4 — Search UI
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P1 | Create `SearchProvider` (debounced, state: idle/loading/results/empty) | 1.5h | 8.2.2 |
| P1 | Create `SearchPage` (search bar, filters, results grid) | 3h | 8.4.1 |
| P1 | Create `SearchResultCard` widget | 0.5h | 8.4.2 |
| P1 | Create `SearchFilters` widget (category chips, price range) | 2h | 8.4.2 |
| P1 | Create `SearchSuggestions` widget (recent/popular queries) | 1h | 8.4.2 |

---

## EPIC 9: Notifications

**Goal:** Push notification receipt via FCM, in-app notification history, deep link handling.
**Priority:** P0 (receive) / P1 (in-app history)
**Total Effort:** 14h

### Story 9.1 — FCM Initialization
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P0 | Initialize Firebase Cloud Messaging in `main.dart` | 0.5h | 1.2.9 |
| P0 | Request notification permissions (Android 13+, iOS) | 0.5h | 9.1.1 |
| P0 | Get FCM token and save to `users/{uid}/fcmToken` | 1h | 9.1.2, 2.1.1 |
| P0 | Handle foreground message (show heads-up notification) | 0.5h | 9.1.1 |
| P0 | Handle background message tap → deep link navigation | 1.5h | 9.1.1, 1.5.1 |

### Story 9.2 — In-App Notification History
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P1 | Create `Notification` entity | 0.5h | — |
| P1 | Create `NotificationDto` | 0.5h | 9.2.1 |
| P1 | Create `NotificationRepository` interface | 0.5h | 9.2.1 |
| P1 | Create `NotificationFirebaseDataSource` | 1.5h | 1.2.6 |
| P1 | Create `NotificationRepositoryImpl` | 1h | 9.2.4 |
| P1 | Create `GetNotificationsUseCase` | 0.5h | 9.2.3 |
| P1 | Create `WatchNotificationsUseCase` | 0.5h | 9.2.3 |
| P1 | Create `MarkNotificationReadUseCase` | 0.5h | 9.2.3 |
| P1 | Create `NotificationProvider` | 1h | 9.2.6 |
| P1 | Create `NotificationListPage` (read/unread, timestamps, deep links) | 2h | 9.2.9 |
| P1 | Create `NotificationTile` widget | 0.5h | 9.2.10 |

---

## EPIC 10: User Management (Admin)

**Goal:** Admin user list viewing, role assignment, account deactivation.
**Priority:** P0
**Total Effort:** 14h

### Story 10.1 — User Domain
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P0 | Create `UserRepository` interface (getUsers, getUser, updateRole, toggleActive) | 0.5h | 2.1.1 |
| P0 | Create `GetUsersUseCase` (paginated) | 0.5h | 10.1.1 |
| P0 | Create `GetUserUseCase` | 0.5h | 10.1.1 |
| P0 | Create `UpdateUserRoleUseCase` | 0.5h | 10.1.1 |
| P0 | Create `ToggleUserActiveUseCase` | 0.5h | 10.1.1 |
| P0 | Create `UpdateProfileUseCase` (self-service) | 0.5h | 10.1.1 |

### Story 10.2 — User Data Layer
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P0 | Create `UserFirebaseDataSource` (admin: list all, update role; self: update profile) | 2h | 10.1.1 |
| P0 | Create `UserRepositoryImpl` | 1.5h | 10.2.1 |
| P0 | Create `UserRepositoryProvider` | 0.5h | 10.2.2 |

### Story 10.3 — User Admin UI
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P0 | Create `AdminUsersProvider` | 1h | 10.1.2-10.1.5 |
| P0 | Create `AdminUsersPage` (search + data table + pagination) | 3h | 10.3.1 |
| P0 | Create `UserDetailDialog` (view details, change role, toggle active) | 2h | 10.3.1 |
| P0 | Create `RoleSelector` dropdown widget | 0.5h | 10.3.3 |

---

## EPIC 11: Settings & Configuration

**Goal:** Key-value settings editor, weight units CRUD, app configuration.
**Priority:** P0
**Total Effort:** 12h

### Story 11.1 — Settings Domain
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P0 | Create `Setting` entity | 0.5h | — |
| P0 | Create `SettingDto` (with type-safe deserialization: string/number/bool) | 1h | 11.1.1 |
| P0 | Create `SettingsRepository` interface | 0.5h | 11.1.1 |
| P0 | Create `GetSettingsUseCase` | 0.5h | 11.1.3 |
| P0 | Create `GetSettingUseCase` (by key) | 0.5h | 11.1.3 |
| P0 | Create `UpdateSettingUseCase` | 0.5h | 11.1.3 |

### Story 11.2 — Settings Data Layer
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P0 | Create `SettingsFirebaseDataSource` | 1h | 1.2.6 |
| P0 | Create `SettingsLocalDataSource` (cache for app startup) | 0.5h | 11.2.1 |
| P0 | Create `SettingsRepositoryImpl` | 1h | 11.2.1, 11.2.2 |
| P0 | Create `SettingsRepositoryProvider` | 0.5h | 11.2.3 |

### Story 11.3 — Weight Units
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P0 | Create `WeightUnit` entity | 0.5h | — |
| P0 | Create `WeightUnitDto` | 0.5h | 11.3.1 |
| P0 | Create `WeightUnitRepository` interface | 0.5h | 11.3.1 |
| P0 | Create `WeightUnitFirebaseDataSource` | 1h | 1.2.6 |
| P0 | Create `WeightUnitRepositoryImpl` | 0.5h | 11.3.4 |

### Story 11.4 — Settings Admin UI
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P0 | Create `AdminSettingsProvider` | 1h | 11.1.4-11.1.6 |
| P0 | Create `AdminSettingsPage` (key-value editor + weight units CRUD) | 3h | 11.4.1 |
| P0 | Create `SettingsFieldEditor` widget (typed input) | 1h | 11.4.2 |
| P0 | Create weight units CRUD section (inline add/edit/delete) | 2h | 11.4.2 |

---

## EPIC 12: Admin Dashboard

**Goal:** Central admin landing page with stats, recent activity, and quick actions.
**Priority:** P0
**Total Effort:** 14h

### Story 12.1 — Admin Dashboard UI
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P0 | Create `AdminSidebar` widget (nav items, active state, RTL-aware) | 3h | 1.5.5 |
| P0 | Create `AdminAppBar` widget (logo, search, notification bell, profile) | 1.5h | — |
| P0 | Create `AdminDashboardProvider` (aggregates counts: products, categories, offers, users) | 2h | 4.2.4, 3.2.5, 5.2.4, 10.2.3 |
| P0 | Create `AdminDashboardPage` (stats cards row + activity feed + quick actions) | 3h | 12.1.3 |
| P0 | Create `AdminStatsCard` widget (icon, count, label) | 0.5h | 12.1.4 |
| P0 | Create responsive admin shell (sidebar → bottom nav on mobile) | 2h | 12.1.1 |
| P0 | Create admin data table widgets (reusable table with sort/filter/pagination) | 2h | — |

---

## EPIC 13: Localization & RTL

**Goal:** Full Arabic and English localization with RTL layout support.
**Priority:** P0
**Total Effort:** 16h

### Story 13.1 — ARB Files
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P0 | Create `app_en.arb` with all MVP English strings | 3h | — |
| P0 | Create `app_ar.arb` with all MVP Arabic translations | 3h | 13.1.1 |
| P0 | Run `flutter gen-l10n` to generate `AppLocalizations` | 0.5h | 13.1.1 |
| P0 | Create `LocaleProvider` (persist preference, expose current locale) | 1h | 13.1.3 |
| P0 | Wire `MaterialApp` with locale resolution + `Directionality` | 1h | 13.1.4 |

### Story 13.2 — Locale-Aware Utilities
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P0 | Create `PriceFormatter` (Eastern Arabic numerals for `ar`, Western for `en`) | 1.5h | 13.1.3 |
| P0 | Create `DateFormatter` (locale-aware date strings) | 1h | 13.1.3 |
| P0 | Create `ErrorLocalizer` (maps Firebase error codes to localized ARB keys) | 1.5h | 13.1.1 |
| P0 | Create `LocalizedText` widget (locale-aware text direction) | 0.5h | 13.1.3 |

### Story 13.3 — RTL Testing & Polish
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P1 | Verify all icons mirror correctly in RTL | 1h | 13.1.5 |
| P1 | Verify all page transitions animate in correct direction | 0.5h | 13.1.5 |
| P1 | Fix any hardcoded left/right padding or alignment | 1h | 13.1.5 |
| P1 | Test with long Arabic strings (no overflow, proper wrapping) | 0.5h | 13.1.2 |

---

## EPIC 14: Profile & Settings (Customer)

**Goal:** Customer profile viewing and editing, language/theme preferences.
**Priority:** P1
**Total Effort:** 10h

### Story 14.1 — Profile UI
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P1 | Create `ProfileProvider` | 1h | 2.1.1, 10.1.6 |
| P1 | Create `ProfilePage` (avatar, name, email, language switcher, sign out) | 2h | 14.1.1 |
| P1 | Create `ProfileHeader` widget | 0.5h | 14.1.2 |
| P1 | Create `LanguageSelector` widget | 1h | 13.1.4 |
| P1 | Create `ThemeSelector` widget (light/dark toggle) | 0.5h | 1.4.4 |

### Story 14.2 — Customer Settings Page
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P1 | Create `SettingsPage` (language, theme, about, app version) | 1.5h | 14.1.4, 14.1.5 |
| P2 | Create `EditProfileForm` (edit name, phone, profile photo) | 2h | 14.1.1 |
| P2 | Upload profile photo to Firebase Storage | 1h | 14.2.2 |

---

## EPIC 15: Profile & Settings (Customer)

**Goal:** Comprehensive test coverage for all layers.
**Priority:** P0 (domain) / P1 (data) / P2 (widget + integration)
**Total Effort:** 36h

### Story 15.1 — Domain Layer Tests
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P0 | Write all entity equality + copyWith tests | 3h | EPICs 2-6 |
| P0 | Write all use case unit tests (auth, category, product, offer, banner) | 10h | EPICs 2-6 |
| P0 | Create `MockAuthRepository` | 0.5h | 2.1.2 |
| P0 | Create `MockProductRepository` | 0.5h | 4.2.1 |
| P0 | Create `MockCategoryRepository` | 0.5h | 3.2.1 |
| P0 | Create `MockOfferRepository` | 0.5h | 5.2.1 |
| P0 | Create `MockBannerRepository` | 0.5h | 6.2.1 |
| P0 | Create `MockUserRepository` | 0.5h | 10.1.1 |
| P0 | Create `MockSettingsRepository` | 0.5h | 11.1.3 |

### Story 15.2 — Data Layer Tests
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P0 | Write DTO round-trip JSON tests for all entities | 4h | EPICs 2-6 |
| P1 | Write repository implementation tests (mocked Firestore) | 8h | EPICs 2-6 |

### Story 15.3 — Widget Tests
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P1 | Write page widget tests (Home, ProductDetail, AdminProducts, etc.) | 6h | EPICs 3-7 |

### Story 15.4 — Integration Tests
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P2 | Write auth flow integration test (sign-up → sign-in → profile) | 3h | EPIC 2 |
| P2 | Write product CRUD integration test | 2h | EPIC 4 |
| P2 | Write category reorder integration test | 2h | EPIC 3 |

---

## EPIC 16: DevOps & Deployment

**Goal:** CI/CD pipeline, Firebase deployment, monitoring.
**Priority:** P1
**Total Effort:** 16h

### Story 16.1 — Firebase Cloud Functions
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P1 | Create `onDeleteCategory` function (reassign products) | 2h | 1.2.9 |
| P1 | Create `onDeleteProduct` function (cleanup offer_products) | 1.5h | 1.2.9 |
| P1 | Create `scheduledDeactivateExpiredOffers` function (daily cron) | 1.5h | 1.2.9 |
| P1 | Create `onNewOffer` function (send push notification) | 2h | 1.2.9, EPIC 9 |

### Story 16.2 — CI/CD
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P2 | Set up GitHub Actions workflow: lint + test on PR | 2h | — |
| P2 | Set up Firebase App Distribution for Android internal testing | 1h | — |
| P2 | Set up Firebase Hosting for web deployment | 1h | — |
| P2 | Set up CodeMagic or similar for iOS build + TestFlight | 2h | — |

### Story 16.3 — Monitoring
| Priority | Task | Effort | Dependencies |
|----------|------|--------|-------------|
| P1 | Enable Firebase Crashlytics for Android + iOS + Web | 1h | — |
| P2 | Enable Firebase Performance Monitoring | 1h | — |
| P2 | Set up custom Firestore usage alerts (reads/writes thresholds) | 0.5h | — |

---

## Summary

| EPIC | Title | Priority | Stories | Tasks | Effort |
|------|-------|----------|---------|-------|--------|
| 1 | Project Setup & Infrastructure | P0 | 7 | 36 | 34h |
| 2 | Authentication & Authorization | P0 | 4 | 22 | 24h |
| 3 | Category Management | P0 | 6 | 27 | 30h |
| 4 | Product Management | P0 | 6 | 34 | 44h |
| 5 | Offer Management | P0 | 6 | 24 | 34h |
| 6 | Banner Management | P0 | 3 | 14 | 18h |
| 7 | Home Screen | P0 | 3 | 19 | 20h |
| 8 | Search | P1 | 4 | 14 | 24h |
| 9 | Notifications | P0/P1 | 2 | 16 | 14h |
| 10 | User Management (Admin) | P0 | 3 | 14 | 14h |
| 11 | Settings & Configuration | P0 | 4 | 19 | 12h |
| 12 | Admin Dashboard | P0 | 1 | 7 | 14h |
| 13 | Localization & RTL | P0 | 3 | 15 | 16h |
| 14 | Profile & Settings (Customer) | P1/P2 | 2 | 8 | 10h |
| 15 | Testing | P0/P1/P2 | 4 | 18 | 36h |
| 16 | DevOps & Deployment | P1/P2 | 3 | 11 | 16h |
| | **Total** | | **61** | **298** | **360h** |

### Rollup by Priority

| Priority | Epic Count | Task Count | Total Effort | % of Total |
|----------|-----------|------------|-------------|------------|
| **P0 (MVP)** | 11 | 240 | 270h | 75% |
| **P1 (Phase 2)** | 4 | 47 | 74h | 21% |
| **P2 (Future)** | 1 | 11 | 16h | 4% |
| **Total** | **16** | **298** | **360h** | **100%** |

### P0 — MVP Total: 270 hours

**Team composition:** 3-4 developers
**Estimated timeline:** 270h ÷ (3 devs × 6h effective/day) = **15 working days (~3 weeks)**

### Key Milestones

| Milestone | Depends On | Estimated End |
|-----------|-----------|--------------|
| M1: Auth + Core Scaffolding | EPICs 1, 2 | Week 1 |
| M2: Categories + Products CRUD | EPICs 3, 4 | Week 2 |
| M3: Offers + Banners + Home Screen | EPICs 5, 6, 7 | Week 2 |
| M4: Admin Dashboard + User Mgmt | EPICs 10, 11, 12 | Week 3 |
| M5: Localization + RTL QA + Testing | EPICs 13, 15 | Week 3 |
| M6: MVP Launch | All P0 | Week 4 |
