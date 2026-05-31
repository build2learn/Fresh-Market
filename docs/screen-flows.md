# Screen Flows & Navigation Map

> **Version:** 1.0.0  
> **Router:** GoRouter with ShellRoute  
> **Guards:** AuthGuard · AdminGuard  

---

## 1. Navigation Architecture

```
MaterialApp.router
  └── GoRouter
       ├── /splash ──────────────► SplashPage           [no guard]
       ├── /sign-in ─────────────► SignInPage            [no guard]
       ├── /sign-up ─────────────► SignUpPage            [no guard]
       │
       ├── ShellRoute (customer shell: bottom nav)       [AuthGuard]
       │    ├── /home ───────────► HomePage
       │    ├── /categories ─────► CategoryProductsPage
       │    ├── /search ─────────► SearchPage
       │    ├── /notifications ──► NotificationListPage
       │    └── /profile ────────► ProfilePage
       │
       ├── /products/:id ────────► ProductDetailPage     [AuthGuard]
       ├── /offers ──────────────► OfferListPage          [AuthGuard]
       ├── /offers/:id ──────────► OfferDetailPage        [AuthGuard]
       │
       ├── ShellRoute (admin shell: sidebar + top bar)   [AuthGuard + AdminGuard]
       │    ├── /admin ──────────► AdminDashboardPage
       │    ├── /admin/products ─► AdminProductsPage
       │    ├── /admin/categories ► AdminCategoriesPage
       │    ├── /admin/offers ───► AdminOffersPage
       │    ├── /admin/banners ──► AdminBannersPage
       │    ├── /admin/users ────► AdminUsersPage
       │    └── /admin/settings ─► AdminSettingsPage
       │
       ├── /admin/products/new ──► AdminProductFormPage   [AdminGuard]
       ├── /admin/products/:id ──► AdminProductFormPage   [AdminGuard]
       ├── /admin/categories/new ► AdminCategoryFormPage  [AdminGuard]
       ├── /admin/categories/:id ► AdminCategoryFormPage  [AdminGuard]
       ├── /admin/offers/new ────► AdminOfferFormPage     [AdminGuard]
       ├── /admin/offers/:id ────► AdminOfferFormPage     [AdminGuard]
       ├── /admin/banners/new ───► AdminBannerFormPage    [AdminGuard]
       └── /admin/banners/:id ───► AdminBannerFormPage    [AdminGuard]
```

---

## 2. Customer Flow Diagram

```mermaid
flowchart TD
    %% ── Entry ──
    AppOpen([App Launch]) --> Splash{Splash Screen}
    Splash -->|Has cached auth| CheckAuth{Authenticated?}
    Splash -->|No cached auth| SignIn[Sign In Page]
    
    SignIn -->|Sign In| CheckAuth
    SignIn -->|Navigate| SignUp[Sign Up Page]
    SignUp -->|Sign Up| CheckAuth
    
    CheckAuth -->|Customer role| Home[Home Page]
    CheckAuth -->|Admin role| AdminDash[Admin Dashboard]
    CheckAuth -->|Unauthenticated| SignIn
    
    %% ── Customer Shell ──
    Home ==>|Bottom Nav: Home| Home
    
    %% ── Home Page ──
    subgraph HomePage[Home Page]
        direction TB
        BannerSec[Banner Carousel<br/>.where isActive == true<br/>.orderBy sortOrder<br/>.limit 10]
        OfferSec[Offers Section<br/>.where isActive == true<br/>.where endDate >= now<br/>.limit 10]
        CatSec[Featured Categories<br/>.where isVisible == true<br/>.orderBy sortOrder<br/>.limit 8]
        ProdSec[Featured Products<br/>.where isFeatured == true<br/>.where isAvailable == true<br/>.limit 20]
    end

    %% ── Navigation from Home ──
    BannerSec -->|Tap banner| BannerLink{linkUrl?}
    BannerLink -->|Offer deep link| OfferDetail[Offer Detail Page]
    BannerLink -->|Product deep link| ProductDetail[Product Detail Page]
    BannerLink -->|No link| Home
    
    OfferSec -->|See All| OfferList[Offer List Page]
    OfferSec -->|Tap offer| OfferDetail
    CatSec -->|Tap category| CatProducts[Category Products Page]
    ProdSec -->|See All| ProdList[Product List Page<br/>all featured]
    ProdSec -->|Tap product| ProductDetail
    
    %% ── Offer List / Detail ──
    subgraph OfferListPage[Offer List Page]
        direction TB
        OList[Offer List<br/>.where isActive == true<br/>.where endDate >= now<br/>.paginated]
    end
    OfferList -->|Tap offer| OfferDetail
    
    subgraph OfferDetailPage[Offer Detail Page]
        direction TB
        OImage[Offer Image 16:9]
        OTitle[Offer Title<br/>Arabic + English]
        ODesc[Offer Description]
        OCountdown[Countdown Timer<br/>endDate - now]
        OProducts[Associated Products Grid<br/>via offer_products join]
    end
    OfferDetail -->|View product| ProductDetail

    %% ── Category Products ──
    subgraph CategoryProductsPage[Category Products Page]
        direction TB
        CatHeader[Category Header<br/>nameAr / nameEn + image]
        CatSort[Sort: Price ▲/▼ | Name]
        CatGrid[Product Grid<br/>.where categoryId == X<br/>.where isAvailable == true<br/>.paginated 20]
    end
    CatProducts -->|Tap product| ProductDetail

    %% ── Product List ──
    subgraph ProductListPage[Product List Page]
        direction TB
        PLSort[Sort: Price ▲/▼ | Name | Newest]
        PLGrid[Product Grid<br/>filtered + paginated 20]
    end
    ProdList -->|Tap product| ProductDetail

    %% ── Product Detail ──
    subgraph ProductDetailPage[Product Detail Page]
        direction TB
        PImage[Product Image<br/>zoomable]
        PName[Product Name<br/>Arabic + English]
        PPrice[Price<br/>localized format]
        PWeight[Weight + Unit]
        PDesc[Description<br/>Arabic + English]
        PAvail[Availability Badge]
        PCat[Category Link]
        POffers[Active Offers containing this product]
    end
    ProductDetail -->|Tap category| CatProducts
    ProductDetail -->|Tap offer| OfferDetail

    %% ── Bottom Nav Destinations ──
    Home -->|Bottom Nav: Categories| CatProducts
    Home -->|Bottom Nav: Search| Search[Search Page]
    Home -->|Bottom Nav: Notifications| Notifs[Notification List Page]
    Home -->|Bottom Nav: Profile| Profile[Profile Page]
    
    %% ── Search ──
    subgraph SearchPage[Search Page]
        direction TB
        SBar[Search Bar<br/>debounced 300ms]
        SFilters[Filters: Category | Price Range]
        SResults[Search Results<br/>Algolia → Firestore]
        SSuggestions[Search Suggestions<br/>recent + popular]
    end
    Search -->|Tap result| ProductDetail

    %% ── Notifications ──
    subgraph NotificationListPage[Notifications Page]
        direction TB
        NList[Notification List<br/>.where userId == uid<br/>.orderBy createdAt desc<br/>.limit 50]
    end
    Notifs -->|Tap notification| NDeepLink{Deep link?}
    NDeepLink -->|Offer| OfferDetail
    NDeepLink -->|Product| ProductDetail
    NDeepLink -->|None| Notifs

    %% ── Profile ──
    subgraph ProfilePage[Profile Page]
        direction TB
        PHeader[Profile Header<br/>photo + name + email]
        PSection[Section: Language Switcher]
        PSection2[Section: App Settings]
        PSignOut[Sign Out Button]
    end
    Profile -->|Sign Out| SignIn
    Profile -->|Change Language| Home
    
    %% ── Off-ramp to Admin ──
    CheckAuth -->|Admin role| AdminEntry[-> Admin Dashboard]
```

---

## 3. Customer Screen Specifications

### 3.1 Splash Screen

```
┌──────────────────────────────────────┐
│                                      │
│                                      │
│                                      │
│              ◉ LOGO                  │  ← 120×120px
│         Fresh Market                 │  ← displayMedium
│        السوق الطازج                  │  ← displaySmall
│                                      │
│                                      │
│         ┌──────────────────┐         │
│         │   جار التحميل    │         │  ← loading spinner
│         │   Loading...     │         │
│         └──────────────────┘         │
│                                      │
│                                      │
└──────────────────────────────────────┘

Purpose:   Firebase init + auth state check
Duration:  ~1.5s or until auth resolves
Decision:
  → Authenticated + admin  → /admin
  → Authenticated + customer → /home
  → Unauthenticated         → /sign-in
Triggers: none (auto-navigate)
```

### 3.2 Sign In / Sign Up

```
┌──────────────────────────────────────┐
│  ←  تسجيل الدخول / Sign In          │  ← app bar
│                                      │
│                                      │
│  ┌────────────────────────────────┐  │
│  │  البريد الإلكتروني             │  │
│  │  Email                    ×   │  │  ← text field
│  └────────────────────────────────┘  │
│                                      │
│  ┌────────────────────────────────┐  │
│  │  كلمة المرور                  │  │
│  │  Password              👁️    │  │  ← text field + toggle
│  └────────────────────────────────┘  │
│                                      │
│  ┌────────────────────────────────┐  │
│  │       تسجيل الدخول             │  │  ← primary button, full width
│  │       Sign In                  │  │
│  └────────────────────────────────┘  │
│                                      │
│  ┌────────────────────────────────┐  │
│  │ أو / Or                        │  │  ← divider
│  └────────────────────────────────┘  │
│                                      │
│  ┌────────────────────────────────┐  │
│  │  ⊗  Google                   │  │  ← outlined button (future)
│  └────────────────────────────────┘  │
│                                      │
│  ليس لديك حساب؟ سجل الآن             │  ← text button link
│  Don't have an account? Sign up     │
└──────────────────────────────────────┘

State: idle → submitting → success | error
Error: inline field errors + top-of-form banner
```

### 3.3 Home Page

```
┌──────────────────────────────────────────────┐
│  ◉ السوق الطازج        🔍  🔔               │  ← app bar
│  Fresh Market                                │
│                                              │
│  ┌──────────────────────────────────────┐    │
│  │  [Banner 1] ← → [Banner 2] ← → ... │    │  ← carousel slider
│  │  bottom dots: ● ● ○ ○               │    │     auto-scroll 4s
│  └──────────────────────────────────────┘    │
│                                              │
│  العروض / Offers              ←  عرض الكل   │  ← section header
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐       │
│  │Offer1│ │Offer2│ │Offer3│ │ ...  │       │  ← horizontal scroll
│  └──────┘ └──────┘ └──────┘ └──────┘       │     160×220px cards
│                                              │
│  التصنيفات / Categories                      │  ← section header
│  ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐             │
│  │ف │ │خ │ │ل │ │  │ │  │ │  │             │  ← grid, 4 cols mobile
│  │Fr│ │Ve│ │Da│ │  │ │  │ │  │             │     6 cols desktop
│  └──┘ └──┘ └──┘ └──┘ └──┘ └──┘             │
│                                              │
│  منتجات مميزة / Featured Products ← المزيد  │  ← section header
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐        │
│  │Prod│ │Prod│ │Prod│ │Prod│ │Prod│        │  ← grid, 2 cols mobile
│  │ P1 │ │ P2 │ │ P3 │ │ P4 │ │ P5 │        │     5 cols desktop
│  └────┘ └────┘ └────┘ └────┘ └────┘        │
│                                              │
├──────┬──────┬──────┬──────┬──────────────────┤
│  🏠  │  📁  │  🔍  │  🔔  │  👤             │
│ Home │ Cat  │Search│ Notif│ Profile          │
└──────┴──────┴──────┴──────┴──────────────────┘

Sections load independently with shimmer skeletons.
Empty sections are hidden (not shown as empty).
```

### 3.4 Category Products Page

```
←  فواكه / Fruits        ←  app bar with back
┌──────────────────────────────────────────────┐
│  ┌──────────────────────────────────────────┐│
│  │  Fruits   ←   فواكه           [Grid/List] ││  ← toggle view
│  └──────────────────────────────────────────┘│
│                                              │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐               │
│  │Prod│ │Prod│ │Prod│ │Prod│               │  ← 2 cols mobile
│  │ P1 │ │ P2 │ │ P3 │ │ P4 │               │     4 cols desktop
│  └────┘ └────┘ └────┘ └────┘               │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐               │
│  │Prod│ │Prod│ │Prod│ │Prod│               │
│  └────┘ └────┘ └────┘ └────┘               │
│                                              │
│  [<]  1  2  3  ...  5  [>]                  │  ← pagination
│                                              │
├──────┬──────┬──────┬──────┬──────────────────┤
│  🏠  │  📁  │  🔍  │  🔔  │  👤             │
└──────┴──────┴──────┴──────┴──────────────────┘

Query: products.where(categoryId == X).where(isAvailable == true).paginated(20)
Sort:  SortChip(price ASC / DESC, name, newest)
```

### 3.5 Product Detail Page

```
←                      🔗  ＊                  ← share + favorite (future)
┌──────────────────────────────────────────────┐
│  ┌──────────────────────────────────────┐    │
│  │                                      │    │
│  │         Product Image                │    │  ← zoomable, 1:1
│  │                                      │    │
│  └──────────────────────────────────────┘    │
│                                              │
│  تفاح أحمد                                  │  ← titleLarge
│  Red Apple                                  │  ← titleSmall, neutral-600
│                                              │
│  ┌─ 4.99 ر.س/ SAR ───────────────────────┐  │  ← headlineMedium, brand-green
│  │                                        │  │
│  └────────────────────────────────────────┘  │
│                                              │
│  📦  1 kg / 1 كغ                            │  ← bodyMedium, neutral-600
│                                              │
│  ┌─ ✅ متوفر / Available ────────────────┐  │  ← chip: success-bg
│  └────────────────────────────────────────┘  │
│                                              │
│  ────────────────────────────────────────    │  ← divider
│                                              │
│  الوصف / Description                         │  ← titleSmall
│  تفاح أحمر طازج من مزارع محلية.              │  ← bodyMedium
│  Fresh red apples from local farms.          │
│  Rich in vitamins...                         │
│                                              │
│  ────────────────────────────────────────    │
│                                              │
│  التصنيف / Category                          │  ← titleSmall
│  ┌──────────────────────────────────────┐    │
│  │  🍎  فواكه / Fruits  ←               │    │  ← tappable card
│  └──────────────────────────────────────┘    │
│                                              │
│  عروض تشمل هذا المنتج                        │  ← section (if applicable)
│  Offers including this product               │
│  ┌──────────────────────────────────────┐    │
│  │  عرض الصيف / Summer Sale    ←        │    │  ← tappable
│  └──────────────────────────────────────┘    │
│                                              │
├──────┬──────┬──────┬──────┬──────────────────┤
│  🏠  │  📁  │  🔍  │  🔔  │  👤             │
└──────┴──────┴──────┴──────┴──────────────────┘
```

### 3.6 Offer List Page

```
←  العروض / Offers
┌──────────────────────────────────────────────┐
│                                              │
│  ┌──────────────────────────────────────┐    │
│  │  Summer Sale                    ←    │    │  ← offer card
│  │  عرض الصيف                           │    │     16:9 image
│  │  ┌──────────────────────────┐        │    │
│  │  │ باقي 5 أيام / 5 days    │        │    │  ← countdown
│  │  └──────────────────────────┘        │    │
│  └──────────────────────────────────────┘    │
│                                              │
│  ┌──────────────────────────────────────┐    │
│  │  New Arrivals                    ←   │    │
│  │  الوافدون الجدد                       │    │
│  └──────────────────────────────────────┘    │
│                                              │
│              [Load More]                      │  ← pagination
│                                              │
├──────┬──────┬──────┬──────┬──────────────────┤
│  🏠  │  📁  │  🔍  │  🔔  │  👤             │
└──────┴──────┴──────┴──────┴──────────────────┘

Query: offers.where(isActive == true).where(endDate >= now).paginated(10)
```

### 3.7 Offer Detail Page

```
←  عرض الصيف / Summer Sale
┌──────────────────────────────────────────────┐
│  ┌──────────────────────────────────────┐    │
│  │                                      │    │
│  │         Offer Image (16:9)           │    │
│  │                                      │    │
│  │  ┌─── عرض الصيف ──────────────────┐  │    │  ← overlay
│  │  │ Summer Sale              ←     │  │    │
│  │  └─────────────────────────────────┘  │    │
│  └──────────────────────────────────────┘    │
│                                              │
│  ⏰  ينتهي بعد / Expires in                  │
│     01 : 12 : 34 : 56                        │  ← countdown, brand-orange
│     days  hrs  min  sec                      │
│                                              │
│  ────────────────────────────────────────    │
│                                              │
│  خصم يصل إلى 30% على جميع الفواكه            │  ← bodyLarge
│  Up to 30% off on all fresh fruits.
│  Limited time offer!
│                                              │
│  ────────────────────────────────────────    │
│                                              │
│  المنتجات المشمولة / Included Products        │  ← titleMedium
│                                              │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐               │
│  │Prod│ │Prod│ │Prod│ │Prod│               │  ← product cards grid
│  │ P1 │ │ P2 │ │ P3 │ │ P4 │               │
│  └────┘ └────┘ └────┘ └────┘               │
│                                              │
├──────┬──────┬──────┬──────┬──────────────────┤
│  🏠  │  📁  │  🔍  │  🔔  │  👤             │
└──────┴──────┴──────┴──────┴──────────────────┘
```

### 3.8 Search Page

```
←  بحث / Search
┌──────────────────────────────────────────────┐
│  ┌────────────────────────────────────────┐  │
│  │  🔍  ابحث عن منتج / Search products   │  │  ← search bar, autofocus
│  └────────────────────────────────────────┘  │
│                                              │
│  ┌──────────────┬──────────────────────────┐ │
│  │              │                          │ │
│  │  التصنيفات   │  نطاق السعر              │ │  ← filter chips
│  │  Categories  │  Price Range             │ │
│  │              │                          │ │
│  │  □ فواكه     │  [Min]  —  [Max]        │ │
│  │  □ خضروات    │                          │ │
│  │  □ ألبان     │                          │ │
│  │  □ لحوم      │                          │ │
│  └──────────────┴──────────────────────────┘ │
│                                              │
│  ── نتائج البحث / Search Results ────────    │
│                                              │
│  ┌────┐ ┌────┐ ┌────┐                       │
│  │Prod│ │Prod│ │Prod│                       │  ← results grid
│  └────┘ └────┘ └────┘                       │
│                                              │
│  عرض 3 من 12 نتيجة                           │  ← results count
│  Showing 3 of 12 results                     │
│                                              │
├──────┬──────┬──────┬──────┬──────────────────┤
│  🏠  │  📁  │  🔍  │  🔔  │  👤             │
└──────┴──────┴──────┴──────┴──────────────────┘

Search: Algolia SDK → product IDs → Firestore whereIn(id, ids)
Debounce: 300ms
Min query length: 2 characters
```

### 3.9 Profile Page

```
←  الملف الشخصي / Profile
┌──────────────────────────────────────────────┐
│                                              │
│         ┌──────────┐                         │
│         │  Photo   │                         │  ← circle, 80px
│         └──────────┘                         │
│                                              │
│         أحمد محمد                            │  ← titleLarge
│         ahmed@example.com                    │  ← bodyMedium, neutral-600
│                                              │
│  ────────────────────────────────────────    │
│                                              │
│  اللغة / Language                             │
│  ┌────────────────────────────────────────┐  │
│  │  العربية        ●                      │  │  ← radio tile
│  │  English        ○                      │  │
│  └────────────────────────────────────────┘  │
│                                              │
│  ────────────────────────────────────────    │
│                                              │
│  ⚙️  الإعدادات / Settings                    │  ← list tile → /settings
│  ℹ️  حول التطبيق / About                     │  ← list tile
│                                              │
│  ────────────────────────────────────────    │
│                                              │
│  ┌────────────────────────────────────────┐  │
│  │          تسجيل الخروج                   │  │  ← text button, error color
│  │          Sign Out                       │  │
│  └────────────────────────────────────────┘  │
│                                              │
├──────┬──────┬──────┬──────┬──────────────────┤
│  🏠  │  📁  │  🔍  │  🔔  │  👤             │
└──────┴──────┴──────┴──────┴──────────────────┘
```

### 3.10 Notification List Page

```
←  الإشعارات / Notifications
┌──────────────────────────────────────────────┐
│                                              │
│  ┌────────────────────────────────────────┐  │
│  │ 🔴 عرض الصيف الجديد!                  │  │  ← unread: bold + red dot
│  │ تفقد عرض الصيف الجديد                  │  │
│  │ منذ ساعتين / 2 hours ago       ●       │  │
│  └────────────────────────────────────────┘  │
│                                              │
│  ┌────────────────────────────────────────┐  │
│  │ ⚪ تم تحديث السعر                      │  │  ← read: normal weight
│  │ تغير سعر التفاح الأحمر إلى 4.99        │  │
│  │ منذ يومين / 2 days ago                 │  │
│  └────────────────────────────────────────┘  │
│                                              │
│  ┌────────────────────────────────────────┐  │
│  │ ⚪ مرحباً بك في السوق الطازج           │  │
│  │ ...                                     │  │
│  └────────────────────────────────────────┘  │
│                                              │
├──────┬──────┬──────┬──────┬──────────────────┤
│  🏠  │  📁  │  🔍  │  🔔  │  👤             │
└──────┴──────┴──────┴──────┴──────────────────┘

Query: notifications.where(userId == uid).orderBy(createdAt desc).limit(50)
Tap:   mark as read + deep link navigation
Badge: app bar icon shows unread count
```

---

## 4. Admin Flow Diagram

```mermaid
flowchart TD
    %% ── Admin Entry ──
    AdminLogin[Admin Sign In] -->|role == admin| AdminDash[Admin Dashboard Page]
    
    %% ── Admin Shell Layout ──
    subgraph AdminShell[Admin Shell (sidebar + top bar)]
        Sidebar[Admin Sidebar]
        TopBar[Top App Bar<br/>logo + search + notifications + profile]
    end
    
    AdminDash --> Sidebar
    AdminDash --> TopBar
    
    %% ── Sidebar Navigation ──
    Sidebar -->|Dashboard| AdminDash
    Sidebar -->|Products| AdminProds[Admin Products Page]
    Sidebar -->|Categories| AdminCats[Admin Categories Page]
    Sidebar -->|Offers| AdminOffers[Admin Offers Page]
    Sidebar -->|Banners| AdminBanners[Admin Banners Page]
    Sidebar -->|Users| AdminUsers[Admin Users Page]
    Sidebar -->|Settings| AdminSettings[Admin Settings Page]
    
    %% ── Dashboard ──
    subgraph AdminDashboardPage[Admin Dashboard Page]
        direction TB
        DStats[Stats Cards Row<br/>Products: 1,234 | Categories: 45<br/>Offers: 12 | Users: 567]
        DRecent[Recent Activity Feed<br/>last 10 admin actions]
        DQuick[Quick Actions<br/>+ Add Product | + Add Category | + Add Offer]
    end
    
    %% ── Product Management ──
    subgraph AdminProductsPage[Admin Products Page]
        direction TB
        PSearch[Search + Filters Bar]
        PTable[Data Table<br/>Image | Name | Price | Category | Status | Actions]
        PPagination[Pagination 50/page]
    end
    AdminProds -->|Click Add| ProdForm[Admin Product Form Page]
    AdminProds -->|Click Edit| ProdForm
    AdminProds -->|Click Delete| ConfirmDel{Confirm Dialog}
    ConfirmDel -->|Confirm| AdminProds
    ConfirmDel -->|Cancel| AdminProds
    
    subgraph AdminProductFormPage[Admin Product Form Page]
        direction TB
        PFImage[Image Uploader<br/>pick + preview + upload]
        PFArName[Arabic Name *]
        PFEnName[English Name *]
        PFArDesc[Arabic Description]
        PFEnDesc[English Description]
        PFPrice[Price *]
        PFWeight[Weight * + Weight Unit Select]
        PFCategory[Category Select (dropdown)]
        PFFeatured[Featured Toggle]
        PFAvailable[Availability Toggle]
        PFSave[Save Button]
    end
    ProdForm -->|Save| AdminProds

    %% ── Category Management ──
    subgraph AdminCategoriesPage[Admin Categories Page]
        direction TB
        CList[Category List<br/>ordered by sortOrder]
        CItem[Each item: Drag Handle | Image | NameAr | NameEn<br/>Visibility Toggle | Edit | Delete]
        CReorder[Drag & Drop Reorder<br/>batch update sortOrder]
    end
    AdminCats -->|Click Add| CatForm[Admin Category Form Page]
    AdminCats -->|Click Edit| CatForm
    
    subgraph AdminCategoryFormPage[Admin Category Form Page]
        direction TB
        CFImage[Image Uploader]
        CFArName[Arabic Name *]
        CFEnName[English Name *]
        CFVisible[Visible Toggle]
        CFSave[Save Button]
    end
    CatForm -->|Save| AdminCats

    %% ── Offer Management ──
    subgraph AdminOffersPage[Admin Offers Page]
        direction TB
        OList[Offer List<br/>Image | Title | Active | Start | End | Actions]
    end
    AdminOffers -->|Click Add| OfferForm[Admin Offer Form Page]
    AdminOffers -->|Click Edit| OfferForm
    
    subgraph AdminOfferFormPage[Admin Offer Form Page]
        direction TB
        OFImage[Image Uploader]
        OFArTitle[Arabic Title *]
        OFEnTitle[English Title *]
        OFArDesc[Arabic Description]
        OFEnDesc[English Description]
        OFActive[Active Toggle]
        OFStart[Start Date Picker]
        OFEnd[End Date Picker]
        OFProducts[Product Selector Dialog<br/>multi-select from product list]
        OFSave[Save Button]
    end
    OfferForm -->|Save| AdminOffers

    %% ── Banner Management ──
    subgraph AdminBannersPage[Admin Banners Page]
        direction TB
        BList[Banner List<br/>ordered by sortOrder]
        BReorder[Drag & Drop Reorder]
    end
    AdminBanners -->|Add / Edit| BannerForm[Admin Banner Form Page]
    
    subgraph AdminBannerFormPage[Admin Banner Form Page]
        direction TB
        BFImage[Image Uploader *<br/>21:9 recommended]
        BFArTitle[Arabic Title]
        BFEnTitle[English Title]
        BFLink[Deep Link Selector<br/>offer / category / product]
        BFActive[Active Toggle]
        BFSave[Save Button]
    end
    BannerForm -->|Save| AdminBanners

    %% ── User Management ──
    subgraph AdminUsersPage[Admin Users Page]
        direction TB
        USearch[Search by name / email]
        UTable[Users Table<br/>Name | Email | Role | Active | Joined | Actions]
    end
    AdminUsers -->|Click user| UserDetail{User Detail Dialog}
    UserDetail -->|Change Role| RoleSelect[Role Selector<br/>admin / customer]
    UserDetail -->|Toggle Active| ConfirmUser{Confirm?}
    ConfirmUser -->|Confirm| AdminUsers
    ConfirmUser -->|Cancel| AdminUsers
    RoleSelect -->|Save| AdminUsers

    %% ── Settings ──
    subgraph AdminSettingsPage[Admin Settings Page]
        direction TB
        SSection[App Settings<br/>key-value editor]
        SWUnits[Weight Units<br/>CRUD lookup table]
        SRoles[Roles Management<br/>(Phase 2)]
    end
    
    AdminUsers -->|Save| AdminUsers
```

---

## 5. Admin Screen Specifications

### 5.1 Admin Dashboard

```
┌──────────────────────────────────────────────────────────────────┐
│  ◉ Fresh Market      🔍 [Search...]    🔔    👤 Admin    🚪     │  ← top bar
├──────────┬───────────────────────────────────────────────────────┤
│          │  لوحة التحكم / Dashboard                              │  ← page title
│ 📊 Dash  │                                                       │
│ 📦 Prods │  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐                │
│ 📁 Cats  │  │ 1,234│ │   45 │ │   12 │ │  567 │                │  ← stats cards
│ 🏷 Offers│  │منتجات│ │تصنيفات│ │عروض │ │مستخدم│                │
│ 🖼 Bnrs  │  └──────┘ └──────┘ └──────┘ └──────┘                │
│ 👥 Users │                                                       │
│ ⚙️ Sets  │  آخر النشاطات / Recent Activity                       │
│          │  ┌───────────────────────────────────────────────┐    │
│          │  │ 🟢 أضاف أحمد منتج "تفاح أحمر"    منذ 5 دقائق│    │  ← activity feed
│          │  │ 🔵 عدّل عمر تصنيف "فواكه"        منذ 20 دقيقة│    │
│          │  │ 🟡 فعّل سارة عرض "عرض الصيف"     منذ ساعة    │    │
│          │  └───────────────────────────────────────────────┘    │
│          │                                                       │
│          │  إجراءات سريعة / Quick Actions                        │
│          │  [+ إضافة منتج]  [+ إضافة تصنيف]  [+ إضافة عرض]     │
│          │                                                       │
└──────────┴───────────────────────────────────────────────────────┘

Sidebar: 240px (desktop) / collapsed 72px (tablet) / bottom nav (mobile)
Stats:   Real-time counts from Firestore aggregation
```

### 5.2 Admin Products Page

```
┌──────────────────────────────────────────────────────────────────┐
│  ◉ Fresh Market                                   👤 Admin       │
├──────────┬───────────────────────────────────────────────────────┤
│ 📊 Dash  │  المنتجات / Products                                 │
│ 📦 Prods │                                                       │
│ 📁 Cats  │  ┌───────────────────────────────────────────────┐    │
│ 🏷 Offers│  │ 🔍 بحث / Search...          [التصنيف: الكل]  │    │  ← search + filter
│ 🖼 Bnrs  │  │                               [+ إضافة منتج] │    │  ← CTA button
│ 👥 Users │  └───────────────────────────────────────────────┘    │
│ ⚙️ Sets  │                                                       │
│          │  ┌────┬──────────┬──────────┬──────┬────────┬──────┐  │
│          │  │ #  │ الاسم    │ السعر    │الحالة│ مميز   │الإجراء│  │  ← table header
│          │  ├────┼──────────┼──────────┼──────┼────────┼──────┤  │
│          │  │ 1  │🍎 تفاح  │  4.99    │ 🟢   │ ⭐     │ ✏️🗑️ │  │  ← row
│          │  │ 2  │🍊 برتقال│  3.50    │ 🟢   │ ○      │ ✏️🗑️ │  │
│          │  │ 3  │🍌 موز   │  2.99    │ 🔴   │ ○      │ ✏️🗑️ │  │
│          │  │ ...│ ...      │  ...     │ ...   │ ...    │ ...  │  │
│          │  └────┴──────────┴──────────┴──────┴────────┴──────┘  │
│          │                                                       │
│          │  [<]  1  2  3  ...  10  [>]    50 لكل صفحة           │
│          │                                                       │
└──────────┴───────────────────────────────────────────────────────┘

Row actions: Edit, Delete, Toggle Featured (⭐/○), Toggle Available (🟢/🔴)
Inline toggles: Click featured star to toggle without opening form
```

### 5.3 Admin Product Form Page

```
←  إضافة منتج / Add Product                    ←  app bar with back
┌──────────────────────────────────────────────────────────────────┐
│  ┌──────────────────────────────────────────────────────────────┐│
│  │  ┌──────────────────────┐   ┌──────────────────────────┐    ││
│  │  │                      │   │  📷 اضغط لرفع الصورة     │    ││  ← image uploader
│  │  │    Image Preview     │   │  Tap to upload image     │    ││
│  │  │                      │   │  (JPEG, PNG, max 5MB)   │    ││
│  │  └──────────────────────┘   └──────────────────────────┘    ││
│  └──────────────────────────────────────────────────────────────┘│
│                                                                   │
│  ┌──────────────┐  ┌──────────────┐                              │
│  │الاسم بالعربية*│  │English Name* │                              │  ← side by side
│  └──────────────┘  └──────────────┘                              │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────────┐│
│  │ الوصف بالعربية / Arabic Description                          ││  ← multiline
│  └──────────────────────────────────────────────────────────────┘│
│  ┌──────────────────────────────────────────────────────────────┐│
│  │ English Description                                         ││  ← multiline
│  └──────────────────────────────────────────────────────────────┘│
│                                                                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐           │
│  │السعر / Price*│  │الوزن/Weight* │  │  الوحدة      │           │
│  │              │  │              │  │  kg / كغ ●   │           │  ← row
│  └──────────────┘  └──────────────┘  │  g / غرام ○  │           │
│                                       │  lb / رطل ○  │           │
│                                       └──────────────┘           │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────────┐│
│  │ التصنيف / Category:  [ فواكه / Fruits  ▼ ]                  ││  ← dropdown
│  └──────────────────────────────────────────────────────────────┘│
│                                                                   │
│  ┌──────────────┐  ┌──────────────┐                              │
│  │ ⭐ مميز      │  │ 🟢 متوفر    │                              │  ← toggles
│  │   Featured   │  │   Available  │                              │
│  │ [═══●═══]    │  │ [═══●═══]    │                              │
│  └──────────────┘  └──────────────┘                              │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────────┐│
│  │                    حفظ / Save                                ││  ← primary button
│  └──────────────────────────────────────────────────────────────┘│
└──────────────────────────────────────────────────────────────────┘

Form validation:
  - nameAr, nameEn: required, 1-200 chars
  - price: required, >= 0
  - weight: required, > 0
  - weightUnitId, categoryId: required, must exist
  - Image: optional, validated on upload
```

### 5.4 Admin Categories Page

```
┌──────────────────────────────────────────────────────────────────┐
│  ◉ Fresh Market                                   👤 Admin       │
├──────────┬───────────────────────────────────────────────────────┤
│ 📊 Dash  │  التصنيفات / Categories             [+ إضافة تصنيف] │
│ 📦 Prods │                                                       │
│ 📁 Cats  │  ┌───────────────────────────────────────────────┐    │
│ 🏷 Offers│  │ ≡  🍎  فواكه / Fruits      🟢     ✏️   🗑️    │    │  ← drag handle
│ 🖼 Bnrs  │  ├───────────────────────────────────────────────┤    │
│ 👥 Users │  │ ≡  🥦  خضروات / Vegetables  🟢     ✏️   🗑️    │    │
│ ⚙️ Sets  │  ├───────────────────────────────────────────────┤    │
│          │  │ ≡  🥛  ألبان / Dairy        🔴     ✏️   🗑️    │    │  ← hidden category
│          │  ├───────────────────────────────────────────────┤    │
│          │  │ ≡  🥩  لحوم / Meat          🟢     ✏️   🗑️    │    │
│          │  └───────────────────────────────────────────────┘    │
│          │                                                       │
│          │  💡 اسحب وأفلت لإعادة الترتيب                         │
│          │  Drag and drop to reorder                             │
└──────────┴───────────────────────────────────────────────────────┘

Visibility toggle: 🟢 visible / 🔴 hidden (instant Firestore update)
Reorder: Drag handle (≡) → batch update all sortOrder values on drop
```

### 5.5 Admin Offers Page

```
┌──────────────────────────────────────────────────────────────────┐
│  ◉ Fresh Market                                   👤 Admin       │
├──────────┬───────────────────────────────────────────────────────┤
│ 📊 Dash  │  العروض / Offers                   [+ إضافة عرض]    │
│ 📦 Prods │                                                       │
│ 📁 Cats  │  ┌────┬──────────┬──────────┬──────┬────────┬──────┐  │
│ 🏷 Offers│  │ #  │ العنوان  │  الحالة  │البداية│ النهاية │الإجراء│  │
│ 🖼 Bnrs  │  ├────┼──────────┼──────────┼──────┼────────┼──────┤  │
│ 👥 Users │  │ 1  │عرض الصيف│ 🟢 نشط   │1/6/26│30/6/26 │✏️🗑️  │  │
│ ⚙️ Sets  │  │ 2  │عرض الخريف│ 🔴 غير   │1/9/26│30/9/26 │✏️🗑️  │  │
│          │  │    │          │   نشط    │      │        │      │  │
│          │  └────┴──────────┴──────────┴──────┴────────┴──────┘  │
│          │                                                       │
│          │  مفاتيح سريعة / Quick Toggles:                        │
│          │  [عرض الصيف: 🟢 نشط] [عرض الخريف: 🔴 غير نشط]       │  ← inline toggle
└──────────┴───────────────────────────────────────────────────────┘

Status: 🟢 Active (isActive == true + within date range)
        🔴 Inactive (isActive == false)
        ⏰ Expired (endDate < now, auto-deactivated by Cloud Function)
Inline toggle: Switch between Active/Inactive without opening form
```

### 5.6 Admin Offer Form Page

```
←  إضافة عرض / Add Offer
┌──────────────────────────────────────────────────────────────────┐
│  ┌──────────────────────────────────────────────────────────────┐│
│  │  ┌──────────────────────┐                                    ││
│  │  │    Image Preview     │  📷 اضغط لرفع صورة العرض          ││  ← image upload
│  │  │     (16:9)          │  Tap to upload offer image         ││
│  │  └──────────────────────┘                                    ││
│  └──────────────────────────────────────────────────────────────┘│
│                                                                   │
│  ┌──────────────┐  ┌──────────────┐                              │
│  │العنوان بالعربية│  │English Title │                              │
│  └──────────────┘  └──────────────┘                              │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────────┐│
│  │ الوصف بالعربية / Arabic Description                          ││
│  └──────────────────────────────────────────────────────────────┘│
│  ┌──────────────────────────────────────────────────────────────┐│
│  │ English Description                                         ││
│  └──────────────────────────────────────────────────────────────┘│
│                                                                   │
│  ┌──────────────────┐  ┌──────────────────┐  ┌────────────────┐ │
│  │ تاريخ البداية     │  │ تاريخ النهاية    │  │ 🟢 نشط        │ │
│  │ Start Date        │  │ End Date          │  │   Active      │ │
│  │ [اختر تاريخ ▼]    │  │ [اختر تاريخ ▼]    │  │ [═══●═══]    │ │
│  └──────────────────┘  └──────────────────┘  └────────────────┘ │
│                                                                   │
│  المنتجات المشمولة / Included Products ─────────────────────────  │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────────┐│
│  │ 🔍 بحث عن منتجات...                          [إضافة منتجات] ││  ← search + multi-select
│  └──────────────────────────────────────────────────────────────┘│
│                                                                   │
│  ┌──────┬──────────────────────────┬──────────┬─────────────────┐│
│  │  ✅  │ 🍎 تفاح أحمر / Red Apple│  4.99    │ [إزالة]         ││  ← selected products
│  │  ✅  │ 🍊 برتقال / Orange      │  3.50    │ [إزالة]         ││
│  └──────┴──────────────────────────┴──────────┴─────────────────┘│
│                                                                   │
│  ┌──────────────────────────────────────────────────────────────┐│
│  │                    حفظ / Save                                ││
│  └──────────────────────────────────────────────────────────────┘│
└──────────────────────────────────────────────────────────────────┘
```

### 5.7 Admin Users Page

```
┌──────────────────────────────────────────────────────────────────┐
│  ◉ Fresh Market                                   👤 Admin       │
├──────────┬───────────────────────────────────────────────────────┤
│ 📊 Dash  │  المستخدمين / Users                                  │
│ 📦 Prods │                                                       │
│ 📁 Cats  │  🔍 [بحث بالاسم أو البريد الإلكتروني / Search...]    │
│ 🏷 Offers│                                                       │
│ 🖼 Bnrs  │  ┌────┬──────────┬────────────────┬──────┬─────────┐  │
│ 👥 Users │  │ #  │ الاسم    │ البريد         │ الصلاحية│ الحالة│  │
│ ⚙️ Sets  │  ├────┼──────────┼────────────────┼──────┼─────────┤  │
│          │  │ 1  │ أحمد    │ ahmed@...      │⬛ أدمن│ 🟢     │  │
│          │  │ 2  │ سارة    │ sara@...       │👤 عميل│ 🟢     │  │
│          │  │ 3  │ محمد    │ mohamed@...    │👤 عميل│ 🔴     │  │  ← deactivated
│          │  └────┴──────────┴────────────────┴──────┴─────────┘  │
│          │                                                       │
│          │  [<]  1  2  3  ...  20  [>]    50 لكل صفحة           │
└──────────┴───────────────────────────────────────────────────────┘

Tap user → dialog:
  ┌──────────────────────────────────────────┐
  │  أحمد محمد                               │
  │  ahmed@example.com                       │
  │  عضو منذ: 15 يناير 2026                  │
  │  آخر دخول: 31 مايو 2026                  │
  │                                          │
  │  الصلاحية / Role: [أدمن / Admin  ▼]      │  ← dropdown
  │                                          │
  │  الحالة / Status: [🟢 نشط / Active]      │  ← toggle
  │                                          │
  │  ┌──────────┐  ┌──────────────────────┐  │
  │  │   إلغاء  │  │      حفظ التغييرات   │  │
  │  └──────────┘  └──────────────────────┘  │
  └──────────────────────────────────────────┘
```

### 5.8 Admin Settings Page

```
┌──────────────────────────────────────────────────────────────────┐
│  ◉ Fresh Market                                   👤 Admin       │
├──────────┬───────────────────────────────────────────────────────┤
│ 📊 Dash  │  الإعدادات / Settings                                 │
│ 📦 Prods │                                                       │
│ 📁 Cats  │  ┌─── إعدادات التطبيق / App Settings ────────────┐   │
│ 🏷 Offers│  │                                                 │   │
│ 🖼 Bnrs  │  │ اسم المتجر/store_name: [السوق الطازج       ]  │   │
│ 👥 Users │  │ العملة/currency:        [SAR                  ]  │   │
│ ⚙️ Sets  │  │ الضريبة/tax_rate:       [15.0        %       ]  │   │
│          │  │ الصيانة/is_maintenance: [○ نعم / ● لا       ]  │   │
│          │  └─────────────────────────────────────────────────┘   │
│          │                                                       │
│          │  ┌─── وحدات الوزن / Weight Units ────────────────┐   │
│          │  │                                                 │   │
│          │  │ كيلوغرام / kg        ✏️  🗑️                    │   │
│          │  │ غرام / g              ✏️  🗑️                    │   │
│          │  │ رطل / lb              ✏️  🗑️                    │   │
│          │  │ [+ إضافة وحدة]                                 │   │
│          │  └─────────────────────────────────────────────────┘   │
│          │                                                       │
│          │  ┌─── الصلاحيات / Roles (Phase 2) ───────────────┐   │
│          │  │ 🚧 قريباً / Coming Soon                        │   │
│          │  └─────────────────────────────────────────────────┘   │
└──────────┴───────────────────────────────────────────────────────┘
```

---

## 6. Navigation Flow Summary

### Customer Routes

| Route | Page | Shell | Guard | Query Params |
|-------|------|-------|-------|-------------|
| `/splash` | SplashPage | None | None | — |
| `/sign-in` | SignInPage | None | None | `?redirect=` |
| `/sign-up` | SignUpPage | None | None | — |
| `/home` | HomePage | Customer | Auth | — |
| `/categories/:id` | CategoryProductsPage | Customer | Auth | `:id` = categoryId |
| `/products/:id` | ProductDetailPage | Customer | Auth | `:id` = productId |
| `/offers` | OfferListPage | Customer | Auth | — |
| `/offers/:id` | OfferDetailPage | Customer | Auth | `:id` = offerId |
| `/search` | SearchPage | Customer | Auth | `?q=`, `?cat=`, `?min=`, `?max=` |
| `/notifications` | NotificationListPage | Customer | Auth | — |
| `/profile` | ProfilePage | Customer | Auth | — |
| `/settings` | SettingsPage | Customer | Auth | — |

### Admin Routes

| Route | Page | Shell | Guard |
|-------|------|-------|-------|
| `/admin` | AdminDashboardPage | Admin | Auth + Admin |
| `/admin/products` | AdminProductsPage | Admin | Auth + Admin |
| `/admin/products/new` | AdminProductFormPage | None | Auth + Admin |
| `/admin/products/:id` | AdminProductFormPage | None | Auth + Admin |
| `/admin/categories` | AdminCategoriesPage | Admin | Auth + Admin |
| `/admin/categories/new` | AdminCategoryFormPage | None | Auth + Admin |
| `/admin/categories/:id` | AdminCategoryFormPage | None | Auth + Admin |
| `/admin/offers` | AdminOffersPage | Admin | Auth + Admin |
| `/admin/offers/new` | AdminOfferFormPage | None | Auth + Admin |
| `/admin/offers/:id` | AdminOfferFormPage | None | Auth + Admin |
| `/admin/banners` | AdminBannersPage | Admin | Auth + Admin |
| `/admin/banners/new` | AdminBannerFormPage | None | Auth + Admin |
| `/admin/banners/:id` | AdminBannerFormPage | None | Auth + Admin |
| `/admin/users` | AdminUsersPage | Admin | Auth + Admin |
| `/admin/settings` | AdminSettingsPage | Admin | Auth + Admin |

### Route Guard Logic

```
AuthGuard:
  if (unauthenticated) → redirect /sign-in?redirect={currentPath}
  if (authenticated)   → allow

AdminGuard:
  if (user.role != admin) → redirect /home
  if (user.role == admin) → allow

Splash Guard: (special)
  if (authenticated + admin)    → redirect /admin
  if (authenticated + customer) → redirect /home
  if (unauthenticated)          → redirect /sign-in
```

---

## 7. Data Refresh Strategy

| Screen | Trigger | Mechanism |
|--------|---------|-----------|
| Home (all sections) | On mount | Firestore `.snapshots()` |
| Home (pull-to-refresh) | User gesture | Invalidate providers via `ref.invalidate()` |
| Category Products | On mount + category change | Stream with `where` filter |
| Product Detail | On mount | `FutureProvider.family(id)` |
| Offer List | On mount | `.snapshots()` with active filter |
| Offer Detail | On mount | Fetch offer + offer_products + products |
| Admin Product List | On mount | `.snapshots()` admin view (all products) |
| Admin Category List | On mount | `.snapshots()` (all categories) |
| Admin Offer List | On mount | `.snapshots()` (all offers) |
| Admin Users | On mount | Future fetch (no real-time needed) |
| Admin Settings | On mount | Future fetch (cache 60s) |
| Profile | On mount | Future fetch user document |
| Notifications | On mount | `.snapshots()` with userId filter |

### Image Loading Strategy
| Component | Resolution | Cache |
|-----------|-----------|-------|
| Product card (grid) | `imageThumbUrl` (200px) | `cached_network_image` |
| Product detail | `imageUrl` (full) | `cached_network_image` |
| Category card | `imageUrl` (400px) | `cached_network_image` |
| Offer card | `imageUrl` (800px) | `cached_network_image` |
| Banner | `imageUrl` (full, 21:9) | `cached_network_image` |
| Admin thumbnails | `imageThumbUrl` (200px) | `cached_network_image` |
