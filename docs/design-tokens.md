# UI Design System — Fresh Market

> **Version:** 1.0.0  
> **Locales:** Arabic (RTL) · English (LTR)  
> **Framework:** Material 3 (M3) · Flutter  

---

## 1. Brand Identity

### Brand Values
- **Fresh** — Vibrant greens, clean whites, natural feel
- **Trustworthy** — Stable blues, grounded neutrals
- **Welcoming** — Warm accents, approachable typography

### Logo Usage
| Variant | Usage |
|---------|-------|
| Full logo with tagline | App bar (web), splash screen |
| Icon only (mark) | App bar (mobile), favicon |
| Arabic logo | Arabic locale |
| English logo | English locale |

---

## 2. Color System

### 2.1 Brand Colors

| Token | Hex | Material Role | Usage |
|-------|-----|---------------|-------|
| `brand-green` | `#2E7D32` | Primary | Main actions, active states, app bar |
| `brand-green-light` | `#4CAF50` | Primary Container | Buttons, selected chips |
| `brand-green-dark` | `#1B5E20` | On Primary | Text on green backgrounds |
| `brand-green-bg` | `#E8F5E9` | Surface Variant | Card backgrounds, sections |
| `brand-orange` | `#FF6F00` | Secondary | Offer banners, sale badges |
| `brand-orange-light` | `#FFB74D` | Secondary Container | Offer section backgrounds |
| `brand-blue` | `#1565C0` | Tertiary | Links, info banners |
| `brand-blue-light` | `#BBDEFB` | Tertiary Container | Info backgrounds |

### 2.2 Neutral Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `neutral-900` | `#212121` | Primary text |
| `neutral-800` | `#424242` | Secondary text |
| `neutral-600` | `#757575` | Hint text, disabled |
| `neutral-400` | `#BDBDBD` | Borders, dividers |
| `neutral-200` | `#EEEEEE` | Card backgrounds (light) |
| `neutral-100` | `#F5F5F5` | Page background |
| `neutral-50` | `#FAFAFA` | Surface background |
| `white` | `#FFFFFF` | Elevated surfaces |
| `black` | `#000000` | Overlay, shadow |

### 2.3 Semantic Colors

| Token | Hex | Material Role | Usage |
|-------|-----|---------------|-------|
| `success` | `#2E7D32` | — | Available, active, in-stock |
| `warning` | `#F57C00` | — | Low stock, expiring soon |
| `error` | `#D32F2F` | Error | Unavailable, errors, delete |
| `info` | `#1565C0` | — | Information, announcements |
| `success-bg` | `#E8F5E9` | Error Container | Success chip background |
| `warning-bg` | `#FFF3E0` | — | Warning toast background |
| `error-bg` | `#FFEBEE` | Error Container | Error chip background |
| `info-bg` | `#E3F2FD` | — | Info chip background |

### 2.4 On-Colors (Text on Colored Backgrounds)

| Background | Text Color |
|-----------|-----------|
| `brand-green` | `white` |
| `brand-green-light` | `brand-green-dark` |
| `brand-orange` | `white` |
| `brand-blue` | `white` |
| `neutral-900` | `white` |
| `white` | `neutral-900` |
| `error` | `white` |
| `success-bg` | `brand-green-dark` |

### 2.5 Dark Mode Tokens

| Light Token | Dark Token | Hex |
|------------|-----------|-----|
| `neutral-900` | `neutral-50` | `#FAFAFA` |
| `neutral-800` | `neutral-200` | `#EEEEEE` |
| `neutral-100` | `neutral-900` | `#212121` |
| `white` | `neutral-800` | `#424242` |
| `brand-green-bg` | `brand-green-dark` | `#1B5E20` |
| `neutral-200` | `neutral-700` | `#616161` |

---

## 3. Typography

### 3.1 Font Families

| Usage | English Font | Arabic Font | Fallback |
|-------|-------------|-------------|----------|
| Display / Headings | `Poppins` | `Cairo` | `sans-serif` |
| Body / Paragraphs | `Poppins` | `Cairo` | `sans-serif` |
| Labels / Captions | `Poppins` | `Cairo` | `sans-serif` |
| Numeric / Prices | `Poppins` | `Cairo` | `sans-serif` |

### 3.2 Type Scale

```dart
class AppTypography {
  // Material 3 type scale mapped to Arabic/English fonts

  // Display — Large, hero sections
  static const displayLarge = TextStyle(
    fontFamily: 'Cairo',  // 'Poppins' for English
    fontSize: 57,
    fontWeight: FontWeight.w700,
    height: 1.12,
    letterSpacing: -0.25,
  );

  static const displayMedium = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 45,
    fontWeight: FontWeight.w700,
    height: 1.15,
  );

  static const displaySmall = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 36,
    fontWeight: FontWeight.w600,
    height: 1.22,
  );

  // Headlines — Section titles
  static const headlineLarge = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  static const headlineMedium = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.29,
  );

  static const headlineSmall = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.33,
  );

  // Titles — Card titles, section headers
  static const titleLarge = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.27,
  );

  static const titleMedium = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.50,
    letterSpacing: 0.15,
  );

  static const titleSmall = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.43,
    letterSpacing: 0.10,
  );

  // Body — Paragraphs, descriptions
  static const bodyLarge = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.50,
    letterSpacing: 0.50,
  );

  static const bodyMedium = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
    letterSpacing: 0.25,
  );

  static const bodySmall = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.33,
    letterSpacing: 0.40,
  );

  // Labels — Buttons, chips, badges
  static const labelLarge = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.43,
    letterSpacing: 0.10,
  );

  static const labelMedium = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.33,
    letterSpacing: 0.50,
  );

  static const labelSmall = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.45,
    letterSpacing: 0.50,
  );
}
```

### 3.3 RTL-Specific Typography Adjustments

| Property | Arabic (RTL) | English (LTR) |
|----------|-------------|---------------|
| Font family | `Cairo` | `Poppins` |
| Line height | +0.05 (Arabic needs more breathing room) | Standard |
| Number alignment | Use Eastern Arabic numerals (٠-٩) | Western numerals (0-9) |
| Font weight | Regular (400) reads better at small sizes | Regular (400) |
| Bold weight | Bold (700) for headings | Bold (700) for headings |

### 3.4 Number / Price Formatting

| Locale | Example | Format |
|--------|---------|--------|
| Arabic | `٤٫٩٩ ر.س` | Eastern Arabic digits, Arabic decimal separator, RTL currency |
| English | `4.99 SAR` | Western digits, dot decimal, LTR currency code |

---

## 4. Spacing System

### 4.1 Base Unit: 4px

```dart
class AppSpacing {
  // Base unit = 4
  static const double xxs = 2;    // 2px — minimal
  static const double xs = 4;     // 4px — icon gaps
  static const double sm = 8;     // 8px — tight spacing
  static const double md = 12;    // 12px — default inner padding
  static const double lg = 16;    // 16px — card padding
  static const double xl = 24;    // 24px — section spacing
  static const double xxl = 32;   // 32px — large section gaps
  static const double xxxl = 48;  // 48px — page margins
  static const double huge = 64;  // 64px — top-level page separation
}
```

### 4.2 Spacing Map

| Token | px | Usage |
|-------|----|-------|
| `space-2` | 2 | Avatar border, divider margin |
| `space-4` | 4 | Icon padding, chip inner padding |
| `space-8` | 8 | Button padding, list tile gap |
| `space-12` | 12 | Card inner padding (condensed) |
| `space-16` | 16 | Card padding, form field padding |
| `space-24` | 24 | Section padding, dialog padding |
| `space-32` | 32 | Section between major blocks |
| `space-48` | 48 | Page edge padding (web) |
| `space-64` | 64 | Top-level layout separation |

### 4.3 Responsive Breakpoints

| Breakpoint | Width | Layout |
|-----------|-------|--------|
| `mobile` | < 600px | Single column, bottom nav |
| `tablet` | 600-1024px | Two column, condensed sidebar |
| `desktop` | > 1024px | Multi-column, full sidebar |

### 4.4 Padding by Breakpoint

| Element | Mobile | Tablet | Desktop |
|---------|--------|--------|---------|
| Page horizontal | 16px | 24px | 48px |
| Card padding | 12px | 16px | 16px |
| Grid gap | 8px | 12px | 16px |
| Section gap | 24px | 32px | 48px |

---

## 5. Border Radius

```dart
class AppRadius {
  static const double none = 0;
  static const double xs = 4;      // Chips, badges
  static const double sm = 8;      // Cards, small components
  static const double md = 12;     // Dialogs, sheets
  static const double lg = 16;     // Large cards
  static const double xl = 24;     // Sections, containers
  static const double full = 999;  // Circular (buttons, avatars)
}
```

---

## 6. Elevation / Shadows

```dart
class AppElevation {
  static const double none = 0;
  static const double xs = 1;      // Subtle card separation
  static const double sm = 2;      // Cards
  static const double md = 4;      // Elevated buttons, dialogs
  static const double lg = 8;      // Bottom sheets, nav bars
  static const double xl = 12;     // Modals
}
```

### Shadow by Component

| Component | Elevation | Notes |
|-----------|-----------|-------|
| Product card | 1 | Subtle, clean |
| Category card | 2 | More depth for images |
| Offer card | 4 | Highlighted |
| Bottom nav | 8 | Floating above content |
| Admin sidebar | 4 | Separates from content |
| Dialog | 12 | Highest focus |
| Button (idle) | 0 | Flat modern look |
| Button (hover) | 2 | Web hover state |
| FAB | 6 | Floating action |

---

## 7. Component Specifications

### 7.1 Buttons

#### Primary Button
```
┌──────────────────────────────┐
│  نص الزر / Button Text       │
└──────────────────────────────┘

Height:   48px (mobile) / 40px (web dense)
Padding:  16px horizontal
Radius:   12px
BG:       brand-green (#2E7D32)
Text:     white, labelLarge weight
Icon:     18px, leading (RTL: trailing)
Elevation: 0 (flat), 2 (hover, web)
State:
  idle:     brand-green bg
  pressed:  brand-green-dark bg
  disabled: neutral-400 bg
  loading:  brand-green bg + spinner
```

#### Secondary Button
```
┌──────────────────────────────┐
│  نص الزر / Button Text       │
└──────────────────────────────┘

Height:   48px / 40px
Padding:  16px horizontal
Radius:   12px
Border:   1.5px brand-green
BG:       transparent
Text:     brand-green, labelLarge
```

#### Text Button
```
┌──────────────────────────────┐
│  نص الزر / Button Text       │
└──────────────────────────────┘

Height:   40px
Padding:  8px horizontal
Radius:   8px
BG:       transparent
Text:     brand-green, labelLarge
Hover:    brand-green-bg (10% opacity)
```

#### Icon Button
```
      ┌──────┐
      │  ◉   │
      └──────┘

Size:     40×40px
Radius:   20px (full)
Icon:     24px
Color:    neutral-800
```

#### Floating Action Button (FAB)
```
      ┌──────┐
      │  ＋  │
      └──────┘

Size:     56×56px
Radius:   16px
BG:       brand-green
Icon:     white, 24px
Elevation: 6
```

### 7.2 Cards

#### Base Card
```
┌──────────────────────────────┐
│                              │
│         Card Content         │
│                              │
└──────────────────────────────┘

Padding:  16px (lg)
Radius:   12px (md)
BG:       white
Elevation: 1 (xs)
Border:   1px neutral-200 (optional)
```

### 7.3 Product Card

```
┌──────────────────────┐
│ ┌──────────────────┐ │
│ │   Product Image   │ │  ← 1:1 aspect ratio, 140×140px (mobile)
│ │    (1:1 ratio)    │ │     200×200px (desktop)
│ └──────────────────┘ │
│                      │
│ تفاح أحمر            │  ← line-clamp: 2, titleSmall
│ Red Apple            │
│                      │
│ 4.99 ر.س / 4.99 SAR │  ← priceLarge, brand-green
│                      │
│ ┌──────────────────┐ │
│ │ 1 kg / 1 كغ     │ │  ← bodySmall, neutral-600
│ └──────────────────┘ │
│                      │
│ [متوفر / Available]  │  ← chip: success-bg / brand-green-dark
└──────────────────────┘

Dimensions:
  Mobile:   160×280px (grid), 2 columns
  Tablet:   180×300px, 3 columns
  Desktop:  200×320px, 4-5 columns

Badges:
  Featured: brand-orange chip at top-left (RTL: top-right)
  Offer:    brand-orange "خصم 30%" banner overlay

States:
  idle:     elevation 1, scale 1.0
  pressed:  elevation 3, scale 0.98
  disabled: opacity 0.5 (when unavailable)
```

### 7.4 Offer Card

```
┌──────────────────────────────────────┐
│ ┌──────────────────────────────────┐ │
│ │     Offer Image (16:9 ratio)     │ │
│ │ ┌──────────────────────────┐     │ │
│ │ │ عرض الصيف / Summer Sale  │ ← overlay at bottom
│ │ │ خصم 30% / 30% OFF       │ ← titleLarge, white
│ │ └──────────────────────────┘     │
│ └──────────────────────────────────┘ │
│                                      │
│ باقي 5 أيام / 5 days remaining       │ ← countdown timer
│ 01 : 12 : 34 : 56                    │ ← brand-orange text
│                                      │
│ خصم يصل إلى 30% على جميع الفواكه     │ ← bodyMedium
│ Up to 30% off on all fresh fruits    │
│                                      │
│ ┌──────────────────────────────────┐ │
│ │   تصفح العرض / Browse Offer     │ │ ← primary button
│ └──────────────────────────────────┘ │
└──────────────────────────────────────┘

Dimensions:
  Mobile:   full-width (margin 16px), max-height 420px
  Desktop:  600×480px

Image:
  16:9 aspect ratio
  Dark gradient overlay on bottom 40% for text readability
```

### 7.5 Category Card

```
     ┌──────────────┐
     │  ┌────────┐  │
     │  │ Image  │  │  ← 80×80px circle
     │  └────────┘  │
     │              │
     │   فواكه      │  ← labelLarge, centered
     │   Fruits     │  ← labelSmall, neutral-600
     └──────────────┘

Dimensions:  120×140px (mobile) / 140×160px (desktop)
Layout:     Grid, 4 columns mobile / 6 columns desktop
Radius:     12px
BG:         brand-green-bg
Elevation:  2
Active:     border 2px brand-green
```

### 7.6 Admin Data Table

```
┌──────────────────────────────────────────────────────────────┐
│  ┌────────────────────────────────────────────────────────┐  │
│  │ Search...                                     [+ Add] │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                               │
│  ┌─────┬──────────┬──────────┬───────┬────────┬───────────┐  │
│  │ ##  │ Name     │ السعر    │ Status│ مخفي  │ Actions   │  │
│  ├─────┼──────────┼──────────┼───────┼────────┼───────────┤  │
│  │  1  │ Apples   │  4.99    │ 🟢   │  🔒   │ ✏️ 🗑️    │  │
│  │  2  │ Oranges  │  3.50    │ 🔴   │  🔓   │ ✏️ 🗑️    │  │
│  └─────┴──────────┴──────────┴───────┴────────┴───────────┘  │
│                                                               │
│  Pagination: [<]  1  2  3 ... 10  [>]    50 per page        │
└──────────────────────────────────────────────────────────────┘

Header height:     56px
Row height:        52px
Border:            1px neutral-200
Header BG:         neutral-100
Hover row BG:      brand-green-bg at 30% opacity
Stripe (alt rows): neutral-50
Radius:            8px
Pagination:        center-aligned, labeled buttons
```

### 7.7 Admin Sidebar

```
┌───────────────────┐
│  ◉  Fresh Market  │  ← logo, 32px height
│                   │
│  ───────────────  │  ← divider
│                   │
│  📊  Dashboard    │  ← selected: brand-green-bg + 4px left border
│  📦  Products     │     (RTL: right border)
│  📁  Categories   │
│  🏷️   Offers      │
│  🖼️   Banners     │
│  👥  Users        │  ← labelLarge, 48px height
│  ⚙️   Settings    │
│                   │
│  ───────────────  │
│                   │
│  👤  Admin Name   │  ← user info at bottom
│  🚪  Sign Out     │
└───────────────────┘

Width:         240px (collapsed: 72px)
BG:            white
Border-right:  1px neutral-200
Item height:   48px
Item radius:   8px
Active:        brand-green-bg bg + brand-green left border (4px)
Hover:         neutral-100 bg
Icon size:     20px
```

### 7.8 Navigation Bars

#### Customer Bottom Navigation (Mobile)
```
┌──────────────────────────────────────────────┐
│                                              │
│                                              │
│           (content area)                     │
│                                              │
│                                              │
├──────┬──────┬──────┬──────┬──────────────────┤
│  🏠  │  📁  │  🔍  │  🔔  │  👤             │
│ Home │ Cat  │Search│ Notif│ Profile          │
└──────┴──────┴──────┴──────┴──────────────────┘

Height:      64px (with top safe area)
Icon:        24px
Label:       labelSmall
Active:      brand-green icon + text
Inactive:    neutral-600 icon + text
BG:          white
Top border:  1px neutral-200
```

#### Admin Navigation (Desktop)
```
┌──────────────────────────────────────────────────────────────┐
│  ◉ Fresh Market    🔍 [Search...]    🔔    👤 Admin    🚪    │
└──────────────────────────────────────────────────────────────┘
        ^ app bar                              ^ top-right icons

Height:      64px
BG:          brand-green
Text:        white
Search:      320px width, white bg, neutral-900 text
```

---

## 8. Form Elements

### 8.1 Text Field

```
┌──────────────────────────────────┐
│  الاسم بالعربية / Name (English) │  ← label, bodySmall, neutral-600
│ ┌────────────────────────────┐   │
│ │  Input text               │   │  ← bodyLarge, neutral-900
│ └────────────────────────────┘   │
│                                  │
│ ── brand-green 2px (focused) ──  │
│ ── neutral-400 1px (idle) ─────  │
│ ── error 2px (error) ─────────── │
│                                  │
│  Error message text              │  ← bodySmall, error
└──────────────────────────────────┘

Height:       56px (filled)
Padding:      16px left (RTL: right)
Radius:       8px
BG:           neutral-100 (filled) / transparent (outlined)
Label:        floating label (14px → 12px on focus)
Prefix:       24px icon optional
Suffix:       visibility toggle, clear button
```

### 8.2 Dropdown / Select

```
┌──────────────────────────────────┐
│  اختر التصنيف / Select Category  │
│ ┌────────────────────────────┐   │
│ │  Fruits / فواكه       ▼   │   │
│ └────────────────────────────┘   │
└──────────────────────────────────┘

Same dimensions as text field
Menu:     expands downward, max 5 items visible
Item:     48px height, bodyLarge
Selected: brand-green checkmark
```

### 8.3 Toggle / Switch

```
       OFF              ON
    ┌──────┐         ┌────────┐
    │  ◯   │         │    ●   │
    └──────┘         └────────┘

Track:    36×20px
Thumb:    16px circle
ON:       brand-green track + white thumb
OFF:      neutral-400 track + white thumb
```

### 8.4 Chip

```

 [فواكه / Fruits ×]     ← standard chip with close
 [ + إضافة / Add + ]    ← action chip
 [متوفر / Available ●]   ← filter chip (selected)

Height:     32px
Padding:    8px horizontal
Radius:     16px (full)
BG:         neutral-100 (idle) / brand-green-bg (selected)
Border:     1px neutral-400
Text:       labelMedium
Icon:       16px
Delete:     trailing 16px × icon
```

---

## 9. Status Indicators

### 9.1 Badge / Chip

| Status | BG | Text | Icon |
|--------|----|------|------|
| Available | `success-bg` | `brand-green` | 🟢 |
| Unavailable | `error-bg` | `error` | 🔴 |
| Featured | `brand-orange-light` | `brand-orange` | ⭐ |
| Active | `success-bg` | `brand-green` | ✅ |
| Inactive | `neutral-200` | `neutral-600` | ⏸️ |
| Expiring soon | `warning-bg` | `warning` | ⏰ |
| New | `info-bg` | `brand-blue` | 🆕 |

### 9.2 Loading States

| Component | Skeleton Shape | Dimensions |
|-----------|---------------|------------|
| Product card | Rectangle + 2 lines | 160×260px |
| Category card | Circle + 2 short lines | 120×150px |
| Offer card | Rectangle (16:9) + 1 line | full-width × 200px |
| Banner | Rectangle (21:9) | full-width × 200px |
| Text line | Full-width line | height 14px |
| Avatar | Circle | 40×40px |

### 9.3 Empty States

```
     ┌──────────┐
     │          │
     │  🛒      │  ← 120×120px illustration
     │          │
     └──────────┘
     لا توجد منتجات
     No products yet
     
     [إضافة منتج / Add Product]
     
Illustration: 120px
Title:        headlineSmall, neutral-800
Description:  bodyMedium, neutral-600
CTA:          primary button
```

---

## 10. Dialog / Modal

```
┌──────────────────────────────────┐
│  ┌────────────────────────────┐  │
│  │                            │  │
│  │   تأكيد الحذف              │  │  ← titleLarge, centered
│  │   Confirm Deletion         │  │
│  │                            │  │
│  │  هل أنت متأكد من حذف       │  │
│  │  هذا المنتج؟               │  │  ← bodyMedium, centered
│  │  Are you sure you want     │  │
│  │  to delete this product?   │  │
│  │                            │  │
│  │  ┌────────┐ ┌──────────┐   │  │
│  │  │ إلغاء  │ │    حذف   │   │  │
│  │  │ Cancel │ │  Delete  │   │  │
│  │  └────────┘ └──────────┘   │  │
│  │  text btn   primary btn    │  │
│  └────────────────────────────┘  │
│                                  │
│  ──── scrim overlay (60% black) ───
└──────────────────────────────────┘

Width:       328px (mobile) / 448px (desktop)
Padding:     24px
Radius:      16px
Elevation:   12
Scrim:       black 60% opacity
Dismiss:     tap outside (for non-destructive)
```

---

## 11. Snackbar / Toast

```
┌──────────────────────────────────────┐
│ ✅  تم حفظ المنتج بنجاح              │
│     Product saved successfully    ✕  │
└──────────────────────────────────────┘

Height:     48px
Padding:    16px
Radius:     8px
BG:         neutral-900
Text:       white, bodyMedium
Icon:       20px leading
Action:     text button (optional)
Dismiss:    trailing × icon
Duration:   4s (success) / 6s (error)
Position:   bottom (mobile) / top-right (web)
```

---

## 12. RTL Layout Rules

### 12.1 Icon Mirroring

| Icon | RTL Behavior |
|------|-------------|
| Arrow back/forward | Mirror (`arrow_back` → `arrow_forward`) |
| Chevron left/right | Mirror |
| Share | Mirror |
| Search | No mirror (symmetric) |
| Home | No mirror |
| Settings (gear) | No mirror |
| Notification (bell) | No mirror |

### 12.2 Alignment Shifts

| Component | LTR | RTL |
|-----------|-----|-----|
| Text align | Left | Right |
| Button icon | Leading | Trailing |
| Card badge | Top-left | Top-right |
| Progress bar | Left→Right | Right→Left |
| Slider | Left min, Right max | Right min, Left max |
| List trailing | Right arrow | Left arrow |
| Form labels | Before field | Before field (Arabic text) |
| Search clear | Right | Left |
| Sidebar | Left side | Right side |

### 12.3 Page Direction Overrides

```dart
// In app.dart — wrap with Directionality based on locale
Directionality(
  textDirection: locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
  child: MaterialApp.router(
    // ...
  ),
);

// For specific widgets that should not mirror
// Example: a progress indicator should stay LTR even in Arabic
Directionality(
  textDirection: TextDirection.ltr,
  child: LinearProgressIndicator(),
);
```

---

## 13. Theme Configuration

```dart
class FreshMarketTheme {
  static ThemeData light({required String locale}) {
    final isRtl = locale == 'ar';
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppColors.brandGreen,
        onPrimary: Colors.white,
        primaryContainer: AppColors.brandGreenLight,
        onPrimaryContainer: AppColors.brandGreenDark,
        secondary: AppColors.brandOrange,
        onSecondary: Colors.white,
        tertiary: AppColors.brandBlue,
        error: AppColors.error,
        surface: Colors.white,
        onSurface: AppColors.neutral900,
      ),
      textTheme: isRtl
          ? _arabicTextTheme
          : _englishTextTheme,
      cardTheme: CardTheme(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandGreen,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.neutral100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.neutral400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.brandGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.error),
        ),
      ),
    );
  }

  static ThemeData dark({required String locale}) {
    // Mirror light() with dark mode tokens
  }
}
```

---

## 14. Responsive Grid

### 14.1 Product Grid

| Breakpoint | Columns | Card Width | Gap | Page Margin |
|-----------|---------|-----------|-----|-------------|
| < 600px | 2 | ~160px | 8px | 16px |
| 600-840px | 3 | ~180px | 12px | 24px |
| 840-1024px | 4 | ~200px | 12px | 24px |
| > 1024px | 5 | ~200px | 16px | 48px |

### 14.2 Category Grid

| Breakpoint | Columns | Card Width | Gap |
|-----------|---------|-----------|-----|
| < 600px | 4 | ~80px | 8px |
| 600-840px | 5 | ~100px | 12px |
| > 840px | 6 | ~120px | 16px |

---

## 15. Iconography

| Icon Set | Usage |
|----------|-------|
| `MaterialIcons` (M3 outlined) | Primary icon set |
| Custom SVG icons | Logo, brand marks |
| Emoji | Status indicators (admin only) |

### Core Icon Mapping

| Context | Icon | Size |
|---------|------|------|
| Home | `Icons.home_outlined` | 24px |
| Categories | `Icons.category_outlined` | 24px |
| Search | `Icons.search` | 24px |
| Notifications | `Icons.notifications_outlined` | 24px |
| Profile | `Icons.person_outline` | 24px |
| Admin Dashboard | `Icons.dashboard_outlined` | 20px |
| Products (admin) | `Icons.inventory_2_outlined` | 20px |
| Offers | `Icons.local_offer_outlined` | 20px |
| Settings | `Icons.settings_outlined` | 20px |
| Add | `Icons.add` | 24px |
| Edit | `Icons.edit_outlined` | 18px |
| Delete | `Icons.delete_outline` | 18px |
| Visibility | `Icons.visibility_outlined` | 18px |
| Visibility Off | `Icons.visibility_off_outlined` | 18px |
| Close | `Icons.close` | 24px |
| Arrow Back | `Icons.arrow_back` / `arrow_forward` (RTL) | 24px |
| Drag Handle | `Icons.drag_handle` | 24px |
| Camera | `Icons.camera_alt_outlined` | 24px |
| Image | `Icons.image_outlined` | 24px |

---

## 16. Animation & Motion

| Component | Animation | Duration | Curve |
|-----------|-----------|----------|-------|
| Page transition | Slide (LTR/RTL aware) | 300ms | `easeInOut` |
| Card press | Scale 1.0 → 0.98 | 100ms | `easeOut` |
| Button press | Scale 1.0 → 0.97 | 80ms | `easeOut` |
| Dialog appear | Fade + scale up | 200ms | `easeOutBack` |
| Snackbar | Slide up from bottom | 250ms | `easeOut` |
| Banner carousel | Auto-scroll (RTL aware) | 400ms per slide | `easeInOut` |
| Skeleton shimmer | Pulsing opacity | 1500ms loop | `easeInOut` |
| List reorder | Drag + drop | 200ms | `easeInOut` |
| Toggle switch | Thumb slide | 150ms | `easeOut` |
| Sidebar expand | Slide in (LTR/RTL aware) | 200ms | `easeOut` |
