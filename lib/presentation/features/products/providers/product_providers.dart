import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_market/data/providers/product_repository_provider.dart';
import 'package:fresh_market/domain/usecases/product/create_product.usecase.dart';
import 'package:fresh_market/domain/usecases/product/update_product.usecase.dart';
import 'package:fresh_market/domain/usecases/product/delete_product.usecase.dart';
import 'package:fresh_market/domain/usecases/product/get_products.usecase.dart';
import 'package:fresh_market/domain/usecases/product/watch_products.usecase.dart';
import 'package:fresh_market/domain/usecases/product/toggle_product.usecase.dart';
import 'product_list_provider.dart';
import 'product_form_provider.dart';

final createProductUseCaseProvider = Provider<CreateProductUseCase>((ref) {
  return CreateProductUseCase(repository: ref.watch(productRepositoryProvider));
});

final updateProductUseCaseProvider = Provider<UpdateProductUseCase>((ref) {
  return UpdateProductUseCase(repository: ref.watch(productRepositoryProvider));
});

final deleteProductUseCaseProvider = Provider<DeleteProductUseCase>((ref) {
  return DeleteProductUseCase(repository: ref.watch(productRepositoryProvider));
});

final getProductsUseCaseProvider = Provider<GetProductsUseCase>((ref) {
  return GetProductsUseCase(repository: ref.watch(productRepositoryProvider));
});

final getProductUseCaseProvider = Provider<GetProductUseCase>((ref) {
  return GetProductUseCase(repository: ref.watch(productRepositoryProvider));
});

final getFeaturedProductsUseCaseProvider = Provider<GetFeaturedProductsUseCase>((ref) {
  return GetFeaturedProductsUseCase(repository: ref.watch(productRepositoryProvider));
});

final watchProductsUseCaseProvider = Provider<WatchProductsUseCase>((ref) {
  return WatchProductsUseCase(repository: ref.watch(productRepositoryProvider));
});

final watchFeaturedProductsUseCaseProvider = Provider<WatchFeaturedProductsUseCase>((ref) {
  return WatchFeaturedProductsUseCase(repository: ref.watch(productRepositoryProvider));
});

final toggleFeaturedUseCaseProvider = Provider<ToggleFeaturedUseCase>((ref) {
  return ToggleFeaturedUseCase(repository: ref.watch(productRepositoryProvider));
});

final toggleAvailabilityUseCaseProvider = Provider<ToggleAvailabilityUseCase>((ref) {
  return ToggleAvailabilityUseCase(repository: ref.watch(productRepositoryProvider));
});

final productListProvider =
    StateNotifierProvider<ProductListNotifier, ProductListState>((ref) {
  return ProductListNotifier(
    getProducts: ref.watch(getProductsUseCaseProvider),
    watchProducts: ref.watch(watchProductsUseCaseProvider),
    toggleFeatured: ref.watch(toggleFeaturedUseCaseProvider),
    toggleAvailability: ref.watch(toggleAvailabilityUseCaseProvider),
    deleteProduct: ref.watch(deleteProductUseCaseProvider),
  );
});

final productFormProvider = StateNotifierProvider.family.autoDispose<
    ProductFormNotifier, ProductFormState, String?>((ref, editId) {
  return ProductFormNotifier(
    createProduct: ref.watch(createProductUseCaseProvider),
    updateProduct: ref.watch(updateProductUseCaseProvider),
    editId: editId,
  );
});
