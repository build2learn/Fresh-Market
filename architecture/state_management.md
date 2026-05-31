# State Management Strategy

## Framework: Riverpod

### Why Riverpod?
- Compile-time safety (no runtime `ProviderNotFoundException`).
- No `BuildContext` dependency for providers.
- Auto-dispose support for memory management.
- Family modifiers for parameterized providers.
- Stream providers for real-time subscriptions.
- Testing-friendly with provider overrides.

## Provider Types Used

### 1. `StreamProvider` - Real-time data
Used for data that changes in real-time via Firestore snapshots. The repository returns `Stream<List<Entity>>` directly from Firestore `.snapshots()`. The use case transforms or filters the stream. The provider watches the repository stream.

```dart
// Repository returns a Stream, not a Future
abstract class ProductRepository {
  Stream<List<Product>> watchProducts({required int limit, DocumentSnapshot? lastDoc});
  Future<List<Product>> getProducts({required int limit, DocumentSnapshot? lastDoc});
}

// Data layer: RepositoryImpl maps Firestore snapshots to domain entities
class ProductRepositoryImpl implements ProductRepository {
  @override
  Stream<List<Product>> watchProducts({required int limit, DocumentSnapshot? lastDoc}) {
    var query = _firestore.collection('products').limit(limit);
    if (lastDoc != null) query = query.startAfterDocument(lastDoc);
    return query.snapshots().map((snapshot) =>
      snapshot.docs.map((doc) => ProductModel.fromFirestore(doc).toEntity()).toList()
    );
  }
}

// Presentation: StreamProvider watches repository directly (or via use case)
final productsStreamProvider = StreamProvider.autoDispose<List<Product>>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.watchProducts(limit: 20);
});
```

### 2. `FutureProvider` - One-time fetch
Used for initial data loading with loading/error states.
```dart
final categoriesProvider = FutureProvider<List<Category>>((ref) {
  return ref.watch(getCategoriesUseCaseProvider).call();
});
```

### 3. `StateNotifierProvider` - Mutable state
Used for forms, authentication state, and complex UI state.
```dart
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(signInUseCaseProvider));
});
```

### 4. `Provider` - Synchronous data/services
Used for dependency injection of services and repositories.
```dart
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});
```

## State Classes

Each feature defines its own state as an immutable class using Freezed.

### Pattern
```dart
@freezed
class ProductListState with _$ProductListState {
  const factory ProductListState({
    @Default([]) List<Product> products,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _ProductListState;
}
```

### Common States
- `AuthState` - `unauthenticated`, `authenticated(User)`, `loading`, `error(String)`
- `CrudState<T>` - `initial`, `loading`, `loaded(T)`, `error(String)`
- `FormState` - `pure`, `submitting`, `success`, `error(String)`

## Data Flow

```
UI Widget
  │
  ▼
Provider (StateNotifierProvider / StreamProvider)
  │
  ▼
Use Case (Domain Layer)
  │
  ▼
Repository (Injected via Provider)
  │
  ▼
Data Source (Firebase / Local)
```

## Real-Time Updates

Firestore `.snapshots()` are wrapped in `StreamProvider`. When a document changes:
1. Firestore emits a new snapshot.
2. StreamProvider rebuilds.
3. Riverpod notifies all dependents.
4. Widgets rebuild with new data.

This eliminates the need for manual event buses or refresh mechanisms.

## Testing
- Providers can be overridden in tests with mock implementations.
- Use `ProviderContainer` for unit testing providers.
- Override repositories with mock implementations.
