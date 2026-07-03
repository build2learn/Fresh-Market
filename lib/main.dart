import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fresh_market/app.dart';
import 'package:fresh_market/firebase_options.dart';
import 'package:fresh_market/core/providers/firebase_providers.dart';
import 'package:fresh_market/core/services/mock_repositories.dart';
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


/// Bump this version whenever seed data changes so stale SharedPreferences
/// is cleared automatically and fresh seeds are applied.
const _dataVersion = 'v4';
const _dataVersionKey = 'mock_data_version';

/// Toggle between mock services and real Firebase production services.
/// Pass --dart-define=USE_MOCK=false to compile/run in real Firebase mode.
const bool useMock = bool.fromEnvironment('USE_MOCK', defaultValue: true);

void main() async {
  print("[BOOT] main started");
  print("[BOOT] bootstrap started");
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  // Clear stale data when seed version changes
  final storedVersion = prefs.getString(_dataVersionKey);
  if (storedVersion != _dataVersion) {
    print("[BOOT] Data version mismatch ($storedVersion != $_dataVersion). Clearing stale mock data.");
    await prefs.clear();
    await prefs.setString(_dataVersionKey, _dataVersion);
    print("[BOOT] Stale data cleared. Fresh seeds will be applied.");
  }

  print("[FIREBASE] initialize start");
  FirebaseInitResult firebaseInitResult = FirebaseInitResult.notInitialized;
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    print("[FIREBASE] initialize success");
    await NotificationService.instance.initialize();
    firebaseInitResult = FirebaseInitResult.initialized;
  } catch (e) {
    print("[FIREBASE] initialize failed: $e");
    firebaseInitResult = FirebaseInitResult.failed(e.toString());
  }

  // Re-read prefs after potential clear
  final freshPrefs = await SharedPreferences.getInstance();

  print("[RUNAPP] runApp called - useMock=$useMock");
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
