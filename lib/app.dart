import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_market/l10n/app_localizations.dart';

import 'package:fresh_market/core/providers/firebase_providers.dart';
import 'package:fresh_market/core/providers/locale_provider.dart';
import 'package:fresh_market/core/theme/app_theme.dart';
import 'package:fresh_market/presentation/routing/app_router.dart';
import 'package:fresh_market/core/services/notification_service.dart';
import 'package:fresh_market/core/constants/route_constants.dart';
import 'package:fresh_market/core/logging/logger.dart';
import 'package:fresh_market/main.dart' as entrypoint;

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class FreshMarketApp extends ConsumerStatefulWidget {
  const FreshMarketApp({super.key});

  @override
  ConsumerState<FreshMarketApp> createState() => _FreshMarketAppState();
}

class _FreshMarketAppState extends ConsumerState<FreshMarketApp> {
  bool _initialized = false;
  StreamSubscription? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    AppLogger.info('[APP] FreshMarketApp.initState - starting locale initialization');
    _initLocaleWithTimeout();
    _initNotificationListener();
  }

  void _initNotificationListener() {
    _notificationSubscription = NotificationService.instance.onMessageReceived.listen((message) {
      AppLogger.info('[FG NOTIFICATION] Notification received: ${message.messageId}');
      final notification = message.notification;
      if (notification != null) {
        final currentLocale = ref.read(localeProvider);
        final isArabic = currentLocale.languageCode == 'ar';
        
        final title = isArabic 
            ? (message.data['titleAr'] ?? notification.title ?? '')
            : (message.data['titleEn'] ?? notification.title ?? '');
        final body = isArabic
            ? (message.data['bodyAr'] ?? notification.body ?? '')
            : (message.data['bodyEn'] ?? notification.body ?? '');

        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(body, style: const TextStyle(color: Colors.white)),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: isArabic ? 'عرض' : 'View',
              textColor: Colors.white,
              onPressed: () {
                ref.read(goRouterProvider).push(RouteConstants.notifications);
              },
            ),
          ),
        );
      }
    });
  }

  Future<void> _initLocaleWithTimeout() async {
    try {
      AppLogger.info('[APP] Loading locale from SharedPreferences...');
      await ref.read(localeProvider.notifier).load().timeout(const Duration(seconds: 5));
      AppLogger.info('[APP] _initLocale - locale loaded');
    } on TimeoutException {
      AppLogger.warning('[APP] _initLocale TIMEOUT after 5s - continuing anyway');
    } catch (e, st) {
      AppLogger.error('[APP] _initLocale error', e, st);
    }
    if (mounted) {
      setState(() => _initialized = true);
      AppLogger.info('[APP] _initialized = true');
    }
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firebaseResult = ref.watch(firebaseInitResultProvider);
    AppLogger.info('[APP] build() - _initialized=$_initialized, firebaseSuccess=${firebaseResult.isSuccess}');
    if (!firebaseResult.isSuccess) {
      AppLogger.warning('[APP] Showing Firebase error screen');
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off, size: 64, color: Theme.of(context).colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    'Firebase initialization failed',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    firebaseResult.error ?? 'Unknown error',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => entrypoint.main(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (!_initialized) {
      AppLogger.info('[APP] Build: waiting for locale initialization');
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    AppLogger.info('[APP] Build: creating router');
    final locale = ref.watch(localeProvider);
    final isArabic = locale.languageCode == 'ar';
    final router = ref.watch(goRouterProvider);

    AppLogger.info('[APP] Build: app ready - routing to splash page');
    return MaterialApp.router(
      title: 'Fresh Market',
      scaffoldMessengerKey: scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,

      locale: locale,
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) return const Locale('ar');
        for (final supported in supportedLocales) {
          if (supported.languageCode == locale.languageCode) {
            return supported;
          }
        }
        return const Locale('ar');
      },

      theme: AppTheme.light(isArabic: isArabic),
      darkTheme: AppTheme.dark(isArabic: isArabic),
      themeMode: ThemeMode.light,

      routerConfig: router,
    );
  }
}

