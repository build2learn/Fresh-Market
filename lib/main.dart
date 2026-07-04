import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fresh_market/app.dart';
import 'package:fresh_market/firebase_options.dart';
import 'package:fresh_market/core/providers/firebase_providers.dart';
import 'package:fresh_market/core/mocks/mock_auth_repository.dart';
import 'package:fresh_market/core/mocks/mock_category_repository.dart';
import 'package:fresh_market/core/mocks/mock_product_repository.dart';
import 'package:fresh_market/core/mocks/mock_offer_repository.dart';
import 'package:fresh_market/core/mocks/mock_weight_unit_repository.dart';
import 'package:fresh_market/core/mocks/mock_settings_repository.dart';
import 'package:fresh_market/core/mocks/mock_user_repository.dart';
import 'package:fresh_market/core/mocks/mock_notification_repository.dart';
import 'package:fresh_market/core/mocks/mock_lookup_repository.dart';
import 'package:fresh_market/core/mocks/mock_order_repository.dart';
import 'package:fresh_market/core/mocks/mock_address_repository.dart';
import 'package:fresh_market/core/mocks/mock_coupon_repository.dart';
import 'package:fresh_market/core/mocks/mock_audit_log_repository.dart';
import 'package:fresh_market/core/mocks/mock_supplier_repository.dart';
import 'package:fresh_market/core/mocks/mock_purchase_order_repository.dart';
import 'package:fresh_market/core/mocks/mock_supplier_payment_repository.dart';
import 'package:fresh_market/core/mocks/mock_stock_history_repository.dart';
import 'package:fresh_market/core/mocks/mock_batch_repository.dart';
import 'package:fresh_market/core/mocks/mock_expense_repository.dart';
import 'package:fresh_market/core/mocks/mock_warehouse_repository.dart';
import 'package:fresh_market/core/services/notification_service.dart';

import 'package:fresh_market/data/providers/auth_repository_provider.dart';
import 'package:fresh_market/data/providers/category_repository_provider.dart';
import 'package:fresh_market/data/providers/product_repository_provider.dart';
import 'package:fresh_market/data/providers/offer_repository_provider.dart';
import 'package:fresh_market/data/providers/weight_unit_repository_provider.dart';
import 'package:fresh_market/data/providers/settings_repository_provider.dart';
import 'package:fresh_market/data/providers/user_repository_provider.dart';
import 'package:fresh_market/data/providers/notification_repository_provider.dart';
import 'package:fresh_market/data/providers/lookup_repository_provider.dart';
import 'package:fresh_market/data/providers/order_repository_provider.dart';
import 'package:fresh_market/data/providers/address_repository_provider.dart';
import 'package:fresh_market/data/providers/coupon_repository_provider.dart';
import 'package:fresh_market/data/providers/audit_log_repository_provider.dart';
import 'package:fresh_market/data/providers/supplier_repository_provider.dart';
import 'package:fresh_market/data/providers/purchase_order_repository_provider.dart';
import 'package:fresh_market/data/providers/stock_history_providers.dart';
import 'package:fresh_market/data/providers/supplier_payment_repository_provider.dart';
import 'package:fresh_market/data/providers/batch_repository_provider.dart';
import 'package:fresh_market/data/providers/expense_repository_provider.dart';
import 'package:fresh_market/data/providers/warehouse_repository_provider.dart';


import 'package:fresh_market/core/logging/logger.dart';
import 'package:fresh_market/config/env_config.dart';

import 'package:flutter/foundation.dart';

/// Bump this version whenever seed data changes so stale SharedPreferences
/// is cleared automatically and fresh seeds are applied.
const _dataVersion = 'v4';
const _dataVersionKey = 'mock_data_version';

/// Toggle between mock services and real Firebase production services.
/// Pass --dart-define=USE_MOCK=true to compile/run in local mock mode.
const bool useMock = bool.fromEnvironment('USE_MOCK', defaultValue: false);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  EnvConfig.init(Flavor.production);
  
  AppLogger.info("[BOOT] main started");
  AppLogger.info("[BOOT] EnvConfig initialized to production");

  if (kReleaseMode && useMock) {
    AppLogger.error("[BOOT] FATAL: Mock mode (USE_MOCK) is not allowed in release mode!");
    throw StateError('Mock mode (USE_MOCK) is not allowed in release mode.');
  }

  final prefs = await SharedPreferences.getInstance();

  // Clear stale data when seed version changes
  final storedVersion = prefs.getString(_dataVersionKey);
  if (storedVersion != _dataVersion) {
    AppLogger.warning("[BOOT] Data version mismatch ($storedVersion != $_dataVersion). Clearing stale mock data.");
    await prefs.clear();
    await prefs.setString(_dataVersionKey, _dataVersion);
    AppLogger.info("[BOOT] Stale data cleared. Fresh seeds will be applied.");
  }

  AppLogger.info("[FIREBASE] initialize start");
  FirebaseInitResult firebaseInitResult = FirebaseInitResult.notInitialized;
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    AppLogger.info("[FIREBASE] initialize success");
    await NotificationService.instance.initialize();
    firebaseInitResult = FirebaseInitResult.initialized;
  } catch (e) {
    AppLogger.error("[FIREBASE] initialize failed: $e");
    firebaseInitResult = FirebaseInitResult.failed(e.toString());
  }

  // Re-read prefs after potential clear
  final freshPrefs = await SharedPreferences.getInstance();

  AppLogger.info("[RUNAPP] runApp called - useMock=$useMock");
  runApp(
    ProviderScope(
      overrides: useMock
          ? [
              firebaseInitResultProvider.overrideWithValue(FirebaseInitResult.initialized),
              sharedPreferencesProvider.overrideWith((ref) => freshPrefs),
              authRepositoryProvider.overrideWithValue(MockAuthRepository(freshPrefs)),
              categoryRepositoryProvider.overrideWithValue(MockCategoryRepository(freshPrefs)),
              productRepositoryProvider.overrideWithValue(MockProductRepository(freshPrefs)),
              offerRepositoryProvider.overrideWithValue(MockOfferRepository(freshPrefs)),
              weightUnitRepositoryProvider.overrideWithValue(MockWeightUnitRepository(freshPrefs)),
              settingsRepositoryProvider.overrideWithValue(MockSettingsRepository(freshPrefs)),
              userRepositoryProvider.overrideWithValue(MockUserRepository(freshPrefs)),
              notificationRepositoryProvider.overrideWithValue(MockNotificationRepository(freshPrefs)),
              lookupRepositoryProvider.overrideWithValue(MockLookupRepository(freshPrefs)),
              orderRepositoryProvider.overrideWithValue(MockOrderRepository(freshPrefs)),
              addressRepositoryProvider.overrideWithValue(MockAddressRepository(freshPrefs)),
              couponRepositoryProvider.overrideWithValue(MockCouponRepository(freshPrefs)),
              auditLogRepositoryProvider.overrideWithValue(MockAuditLogRepository(freshPrefs)),
              supplierRepositoryProvider.overrideWithValue(MockSupplierRepository(freshPrefs)),
              purchaseOrderRepositoryProvider.overrideWithValue(MockPurchaseOrderRepository(freshPrefs)),
              stockHistoryRepositoryProvider.overrideWithValue(MockStockHistoryRepository(freshPrefs)),
              supplierPaymentRepositoryProvider.overrideWithValue(MockSupplierPaymentRepository(freshPrefs)),
              batchRepositoryProvider.overrideWithValue(MockBatchRepository(freshPrefs)),
              expenseRepositoryProvider.overrideWithValue(MockExpenseRepository(freshPrefs)),
              warehouseRepositoryProvider.overrideWithValue(MockWarehouseRepository(freshPrefs)),
            ]
          : [
              firebaseInitResultProvider.overrideWithValue(firebaseInitResult),
              sharedPreferencesProvider.overrideWith((ref) => freshPrefs),
            ],
      child: const FreshMarketApp(),
    ),
  );
}
