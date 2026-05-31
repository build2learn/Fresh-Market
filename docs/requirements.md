# Requirements Document

## Functional Requirements

### F1 - Home Screen
- F1.1 Display a banner slider with promotional content (from `banners` collection).
- F1.2 Display an offers section showing active offers.
- F1.3 Display featured categories with category images.
- F1.4 Display featured products grid.
- F1.5 All sections must support real-time updates with independent loading states.

### F2 - Categories
- F2.1 Fetch and display dynamic categories from Firestore.
- F2.2 Add new categories with Arabic and English names.
- F2.3 Edit existing category names and images.
- F2.4 Hide/show categories without deletion.
- F2.5 Reorder categories with drag-and-drop.
- F2.6 Upload and associate category images.
- F2.7 Display category image alongside localized name.

### F3 - Products
- F3.1 Display product with image, localized name, description, price, weight, and weight unit.
- F3.2 Mark products as featured or non-featured.
- F3.3 Toggle product availability.
- F3.4 Associate products with a category.
- F3.5 Filter and search products by name, category, and price range.
- F3.6 Real-time product updates on all clients.

### F4 - Offers
- F4.1 Create offers with image, localized title, description, start/end dates.
- F4.2 Toggle offer active/inactive status.
- F4.3 Associate multiple products with a single offer.
- F4.4 Display active offers on the home screen.
- F4.5 Real-time offer updates on all clients.

### F5 - Admin Dashboard
- F5.1 Product management (CRUD with image upload).
- F5.2 Category management (CRUD, reorder, hide/show).
- F5.3 Offer management (CRUD, activate/deactivate).
- F5.4 User management (view, assign roles).
- F5.5 Settings management (weight units, app settings).
- F5.6 Lookup management (weight units, roles).

### F6 - Authentication
- F6.1 Email/password authentication.
- F6.2 Role-based access (admin, customer).
- F6.3 Protected admin routes with redirect.
- F6.4 Persistent authentication state.

### F7 - Notifications
- F7.1 Push notifications via Firebase Cloud Messaging.
- F7.2 Notification for new offers and product updates.
- F7.3 In-app notification history.

### F8 - Banners
- F8.1 Manage promotional banners with Arabic/English titles and images.
- F8.2 Toggle banner active/inactive.
- F8.3 Reorder banners for home screen display.
- F8.4 Add deep link URL to banners for targeted navigation.

## Non-Functional Requirements

### NFR1 - Performance
- NFR1.1 Initial load time under 3 seconds on 4G.
- NFR1.2 Smooth 60fps scrolling in product lists.
- NFR1.3 Pagination with 20 items per page.

### NFR2 - Scalability
- NFR2.1 Support up to 10,000 products.
- NFR2.2 Support up to 500 concurrent users.
- NFR2.3 Firestore read/write limits respected with caching.

### NFR3 - Security
- NFR3.1 Firebase Security Rules enforce role-based access.
- NFR3.2 Admin operations restricted to admin role.
- NFR3.3 No sensitive data exposed in client code.

### NFR4 - Reliability
- NFR4.1 Offline-first with local caching.
- NFR4.2 Graceful degradation when offline.
- NFR4.3 Automatic retry on network failure.

### NFR5 - Maintainability
- NFR5.1 Clean Architecture layering enforced.
- NFR5.2 Feature-first organization.
- NFR5.3 80%+ unit test coverage for domain layer.
- NFR5.4 Complete API documentation.
