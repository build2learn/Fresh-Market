import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/entities/product.entity.dart';
import 'package:fresh_market/domain/entities/user.entity.dart';
import 'package:fresh_market/domain/entities/audit_log.entity.dart';
import 'package:fresh_market/domain/entities/notification.entity.dart';
import 'package:fresh_market/core/enums/user_role.dart';
import 'package:fresh_market/core/enums/notification_type.dart';
import 'package:fresh_market/core/services/mock_repositories.dart';
import 'package:fresh_market/presentation/features/products/providers/product_providers.dart';
import 'package:fresh_market/presentation/features/products/providers/product_form_provider.dart';
import 'package:fresh_market/presentation/features/auth/providers/auth_providers.dart';
import 'package:fresh_market/data/providers/product_repository_provider.dart';
import 'package:fresh_market/data/providers/notification_repository_provider.dart';
import 'package:fresh_market/data/providers/audit_log_repository_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Product Module UAT & Function Testing', () {
    late SharedPreferences prefs;
    late MockProductRepository productRepo;
    late MockNotificationRepository notificationRepo;
    late MockAuditLogRepository auditLogRepo;

    final adminUser = UserEntity(
      id: 'admin_user',
      email: 'admin@freshmarket.com',
      displayName: 'System Administrator',
      role: UserRole.admin,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      productRepo = MockProductRepository(prefs);
      notificationRepo = MockNotificationRepository(prefs);
      auditLogRepo = MockAuditLogRepository(prefs);
    });

    test('E2E Product Lifecycle: Admin Create -> Edit -> Notification -> Audit -> Storefront Search -> Customer Cart Deduction', () async {
      // Create ProviderContainer with repository overrides and initial Admin user
      final container = ProviderContainer(
        overrides: [
          productRepositoryProvider.overrideWithValue(productRepo),
          notificationRepositoryProvider.overrideWithValue(notificationRepo),
          auditLogRepositoryProvider.overrideWithValue(auditLogRepo),
          currentUserProvider.overrideWithValue(adminUser),
        ],
      );
      addTearDown(container.dispose);

      // --- PHASE 1: ADMIN PRODUCT CREATION ---
      // Read the form provider in creation mode (editId = null)
      final formNotifier = container.read(productFormProvider(null).notifier);

      formNotifier.setNameAr('تفاح أحمر طازج');
      formNotifier.setNameEn('Fresh Red Apple');
      formNotifier.setDescriptionAr('تفاح أحمر طازج عالي الجودة');
      formNotifier.setDescriptionEn('Fresh high-quality red apples');
      formNotifier.setPrice('40.0');
      formNotifier.setWeight('1.0');
      formNotifier.setWeightUnitId('kg');
      formNotifier.setCategoryId('cat_frozen');
      formNotifier.setStockQuantity('250');
      formNotifier.setMinStock('20');
      formNotifier.setAlertQuantity('10');
      formNotifier.setFeatured(true);
      formNotifier.setAvailable(true);

      // Assert validation holds
      final stateBeforeSubmit = container.read(productFormProvider(null));
      expect(stateBeforeSubmit.isValid, isTrue, reason: 'Product form data should be valid');

      // Submit form
      final submitError = await formNotifier.submit();
      expect(submitError, isNull, reason: 'Form submission should succeed without errors');

      // Fetch products to verify existence of newly added product
      final productsResult = await productRepo.getProducts(limit: 100);
      expect(productsResult, isA<Success<List<ProductEntity>>>());
      final productList = (productsResult as Success<List<ProductEntity>>).data;
      
      final createdProduct = productList.firstWhere((p) => p.nameEn == 'Fresh Red Apple');
      expect(createdProduct, isNotNull);
      expect(createdProduct.nameAr, 'تفاح أحمر طازج');
      expect(createdProduct.price, 40.0);
      expect(createdProduct.stockQuantity, 250);
      expect(createdProduct.isFeatured, isTrue);

      // Verify Audit Log generation
      final auditLogsResult = await auditLogRepo.getAuditLogs();
      expect(auditLogsResult, isA<Success<List<AuditLogEntity>>>());
      final auditLogs = (auditLogsResult as Success<List<AuditLogEntity>>).data;
      expect(auditLogs.any((log) => log.action == 'Create Product' && log.details.contains('Fresh Red Apple')), isTrue);

      // Verify Push Notification broadcast
      final notificationsResult = await notificationRepo.getNotifications('all');
      expect(notificationsResult, isA<Success<List<NotificationEntity>>>());
      final notifications = (notificationsResult as Success<List<NotificationEntity>>).data;
      expect(notifications.any((notif) => notif.title == 'New Product Added' && notif.userId == 'all'), isTrue);

      // --- PHASE 2: ADMIN PRODUCT EDIT ---
      // Read the form provider in edit mode for our created product ID using the same container
      final editNotifier = container.read(productFormProvider(createdProduct.id).notifier);
      // Wait for repository to load the product data
      await Future.delayed(const Duration(milliseconds: 1500));

      // Verify loaded product data directly from repository
      final loadedProductResult = await productRepo.getProduct(createdProduct.id);
      expect(loadedProductResult, isA<Success<ProductEntity>>());
      final loadedProduct = (loadedProductResult as Success<ProductEntity>).data;
      expect(loadedProduct.nameEn, 'Fresh Red Apple');
      expect(loadedProduct.price, 40.0);

      // Edit price to 45.0
      editNotifier.setPrice('45.0');
      final editSubmitError = await editNotifier.submit();
      expect(editSubmitError, isNull, reason: 'Product editing submission should succeed');

      // Verify updated values in the database
      final updatedProductResult = await productRepo.getProduct(createdProduct.id);
      expect(updatedProductResult, isA<Success<ProductEntity>>());
      final updatedProduct = (updatedProductResult as Success<ProductEntity>).data;
      expect(updatedProduct.price, 45.0);

      // Verify price change audit log and notification
      final updatedAuditLogs = (await auditLogRepo.getAuditLogs() as Success<List<AuditLogEntity>>).data;
      expect(updatedAuditLogs.any((log) => log.action == 'Price Changed' && log.details.contains('from 40.0 to 45.0')), isTrue);

      final updatedNotifications = (await notificationRepo.getNotifications('all') as Success<List<NotificationEntity>>).data;
      expect(updatedNotifications.any((notif) => notif.title == 'Price Updated' && notif.body.contains('45.0 EGP')), isTrue);

      // --- PHASE 3: CUSTOMER STOREFRONT SEARCH ---
      // Search for English name partial match "Apple"
      final searchResultEn = await productRepo.searchProducts('Apple');
      expect(searchResultEn, isA<Success<List<ProductEntity>>>());
      final searchEnData = (searchResultEn as Success<List<ProductEntity>>).data;
      expect(searchEnData.any((p) => p.nameEn == 'Fresh Red Apple' && p.price == 45.0), isTrue);

      // Search for Arabic name match "تفاح"
      final searchResultAr = await productRepo.searchProducts('تفاح');
      expect(searchResultAr, isA<Success<List<ProductEntity>>>());
      final searchArData = (searchResultAr as Success<List<ProductEntity>>).data;
      expect(searchArData.any((p) => p.nameEn == 'Fresh Red Apple'), isTrue);

      // --- PHASE 4: CLIENT CART AND STOCK RESERVATION / DEDUCTION ---
      // Simulating client order creation (decrementing inventory by 2 units)
      final productBeforeCheckout = (await productRepo.getProduct(createdProduct.id) as Success<ProductEntity>).data;
      expect(productBeforeCheckout.stockQuantity, 250);

      // Deducting 2 units (simulate Checkout using adjustStock or receiveStock)
      final checkoutResult = await productRepo.receiveStock(createdProduct.id, -2);
      expect(checkoutResult, isA<Success<void>>());

      final productAfterCheckout = (await productRepo.getProduct(createdProduct.id) as Success<ProductEntity>).data;
      expect(productAfterCheckout.stockQuantity, 248, reason: 'Stock should decrease by 2 units');
    });
  });
}
