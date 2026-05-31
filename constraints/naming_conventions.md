# Naming Conventions

## Dart/Flutter

### Files and Directories
- **Files**: `snake_case` - `product_repository.dart`, `sign_in_usecase.dart`
- **Directories**: `snake_case` - `usecases/`, `featured_products/`
- **Test files**: `{name}_test.dart` - `get_products_usecase_test.dart`
- **ARB files**: `app_{locale}.arb` - `app_en.arb`, `app_ar.arb`

### Classes and Types
- **Classes**: `PascalCase` - `ProductRepository`, `SignInUseCase`
- **Mixin**: `PascalCase` - `RefreshableState`
- **Enum**: `PascalCase` - `UserRole`, `RequestState`
- **Enum values**: `camelCase` - `UserRole.admin`, `RequestState.loading`
- **Type aliases**: `PascalCase` - `ProductList`, `JsonMap`

### Functions and Methods
- **Functions**: `camelCase` - `getProducts()`, `signIn()`
- **Private**: `_camelCase` - `_validateInput()`
- **Getters**: `camelCase` - `get isActive`, `get formattedPrice`

### Variables and Constants
- **Local variables**: `camelCase` - `productList`, `userName`
- **Constants**: `camelCase` - `const defaultPageSize = 20`
- **Private constants**: `_camelCase` - `const _maxRetries = 3`
- **Static constants (public)**: `camelCase` - `static const pageSize = 20`

### Parameters
- **Named parameters**: `camelCase` - `{required String name, int? age}`
- **Positional parameters**: `camelCase` - `void addProduct(Product product)`

## Architecture-Specific Naming

### Domain Layer
- **Entities**: `Product`, `Category` (plain object, no suffix)
- **Repository interfaces**: `ProductRepository` (interface, `lib/domain/repositories/`)
- **Use Cases**: `GetProductsUseCase`, `CreateProductUseCase`

### Data Layer
- **DTOs**: `ProductDto` (suffix `Dto`)
- **Models**: `ProductModel` (suffix `Model`)
- **Repository impls**: `ProductRepositoryImpl` (suffix `Impl`)
- **Data Sources**: `ProductFirebaseDataSource`, `ProductLocalDataSource`

### Presentation Layer
- **Pages**: `ProductListPage`, `HomePage` (suffix `Page`)
- **Widgets**: `ProductCard`, `BannerSlider` (descriptive names)
- **Providers**: `ProductListProvider`, `AuthProvider` (suffix `Provider`)
- **States**: `ProductListState`, `AuthState` (suffix `State`)
- **Notifiers**: `AuthNotifier`, `ProductFormNotifier` (suffix `Notifier`)

## Firebase
- **Collections**: `snake_case` - `weight_units`, `offer_products`
- **Documents**: auto-generated IDs
- **Fields**: `camelCase` - `nameAr`, `nameEn`, `isActive`

## Localization
- **Keys**: `camelCase` - `appName`, `homeTitle`, `addToCart`
- **Context keys**: `{feature}{description}` - `productName`, `categoryTitle`
