# Riverpod State Management Skill

## Provider Types Reference

### Provider
```dart
// Synchronous dependency injection
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});
```

### FutureProvider
```dart
// Async data fetching
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final useCase = ref.watch(getCategoriesUseCaseProvider);
  return useCase();
});
```

### StreamProvider
```dart
// Real-time data streams (Firestore snapshots)
final productsStreamProvider = StreamProvider<List<Product>>((ref) {
  final useCase = ref.watch(watchProductsUseCaseProvider);
  return useCase();
});
```

### StateNotifierProvider
```dart
// Mutable state management
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(signInUseCaseProvider));
});
```

### FutureProvider.family
```dart
// Parameterized provider
final productProvider = FutureProvider.family<Product, String>((ref, id) {
  final useCase = ref.watch(getProductUseCaseProvider);
  return useCase(id);
});
```

## Testing with Provider Overrides
```dart
void main() {
  test('product list state', () {
    final container = ProviderContainer(
      overrides: [
        productsStreamProvider.overrideWith((ref) => Stream.value([])),
      ],
    );
    // test...
  });
}
```

## Best Practices
- Use `ref.watch` for reactive dependencies.
- Use `ref.read` for one-time actions (callbacks, events).
- Use `ref.invalidate` to refresh a provider's state.
- Keep providers in feature-specific files.
- Use `autoDispose` for ephemeral state.
