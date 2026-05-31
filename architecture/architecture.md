# System Architecture

## Architecture Pattern: Clean Architecture

The application follows Clean Architecture principles with three distinct layers:

### Layer 1: Presentation Layer (lib/presentation)
- **Responsibility**: UI rendering and user interaction.
- **Contains**: Pages, Widgets, Providers (Riverpod), Routing.
- **Constraints**: No business logic. No direct Firestore calls. All strings localized.
- **Dependencies**: Depends only on domain layer.

### Layer 2: Domain Layer (lib/domain)
- **Responsibility**: Business logic and enterprise rules.
- **Contains**: Entities, Repository interfaces, Use Cases.
- **Constraints**: Pure Dart. No framework dependencies. No platform imports. All entities immutable.
- **Dependencies**: No dependencies on other layers.

### Layer 3: Data Layer (lib/data)
- **Responsibility**: Data retrieval, storage, and external communication.
- **Contains**: DTOs, Models, Repository implementations, Data Sources (Firebase, Local).
- **Constraints**: Implements domain repository interfaces. Handles data mapping between DTOs and entities.
- **Dependencies**: Depends on domain layer.

## Dependency Rule
Dependencies point inward. The domain layer has no external dependencies. The data layer depends on the domain layer. The presentation layer depends on the domain layer.

## Data Flow
1. UI triggers an action via a Provider/Riverpod notifier.
2. The notifier calls a Use Case from the domain layer.
3. The Use Case calls a Repository interface (injected).
4. The Repository implementation fetches/saves data from Data Sources.
5. Data flows back up: Data Source → Repository → Use Case → Provider → UI rebuilds.

## State Management: Riverpod
- Providers are the single source of truth.
- Stream providers for real-time Firestore subscriptions.
- State notifiers for CRUD operations with form states.
- Auto-dispose providers for memory management.

## Offline-First Strategy
- Local SQLite/Hive cache for product, category, and offer data.
- Firestore persistence enabled for offline reads.
- Optimistic UI updates with background sync.
- Conflict resolution with last-write-wins strategy.

## Responsive Design
- LayoutBuilder and breakpoints for mobile/tablet/web adaptation.
- Adaptive widgets that render differently based on screen size.
- Admin dashboard uses a side-navigation layout on web.
- Customer app uses bottom-navigation layout on mobile.

## Navigation
- GoRouter for declarative routing with deep linking.
- ShellRoute for persistent navigation shells.
- Redirect guards for authentication and role-based access.

## Full-Text Search Strategy
Firestore does not natively support full-text search. For product search by name, we integrate Algolia:

- **Indexing**: Firebase Extensions `firestore-algolia-search` syncs Firestore `products` collection to Algolia index on every write.
- **Search flow**: User types query → Algolia SDK performs search → returns matching product IDs → app fetches full product documents from Firestore via `where('id', whereIn: ids)`.
- **Filtering**: Combined with Algolia facet filters for category and price range.
- **Fallback**: For small datasets (<500 products), client-side filtering with `where('nameAr', isGreaterThanOrEqualTo: query)` as a simple prefix match.
- **Seed data**: Algolia index must be populated on initial product import.
