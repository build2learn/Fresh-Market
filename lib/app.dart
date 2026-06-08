import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_market/l10n/app_localizations.dart';

import 'package:fresh_market/core/providers/firebase_providers.dart';
import 'package:fresh_market/core/providers/locale_provider.dart';
import 'package:fresh_market/core/services/bootstrap.dart';
import 'package:fresh_market/core/theme/app_theme.dart';
import 'package:fresh_market/presentation/routing/app_router.dart';

class FreshMarketApp extends ConsumerStatefulWidget {
  const FreshMarketApp({super.key});

  @override
  ConsumerState<FreshMarketApp> createState() => _FreshMarketAppState();
}

class _FreshMarketAppState extends ConsumerState<FreshMarketApp> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    debugPrint('[APP] FreshMarketApp.initState - starting locale initialization');
    _initLocaleWithTimeout();
  }

  Future<void> _initLocaleWithTimeout() async {
    try {
      debugPrint('[APP] Loading locale from SharedPreferences...');
      await ref.read(localeProvider.notifier).load().timeout(const Duration(seconds: 5));
      debugPrint('[APP] _initLocale - locale loaded');
    } on TimeoutException {
      debugPrint('[APP] _initLocale TIMEOUT after 5s - continuing anyway');
    } catch (e, st) {
      debugPrint('[APP] _initLocale error: $e\n$st');
    }
    if (mounted) {
      setState(() => _initialized = true);
      debugPrint('[APP] _initialized = true');
    }
  }

  @override
  Widget build(BuildContext context) {
    final firebaseResult = ref.watch(firebaseInitResultProvider);
    debugPrint('[APP] build() - _initialized=$_initialized, firebaseSuccess=${firebaseResult.isSuccess}');
    if (!firebaseResult.isSuccess) {
      debugPrint('[APP] Showing Firebase error screen');
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
                    onPressed: () => Bootstrap.run(),
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
      debugPrint('[APP] Build: waiting for locale initialization');
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    debugPrint('[APP] Build: creating router');
    final locale = ref.watch(localeProvider);
    final isArabic = locale.languageCode == 'ar';
    final router = ref.watch(goRouterProvider);

    debugPrint('[APP] Build: app ready - routing to splash page');
    return MaterialApp.router(
      title: 'Fresh Market',
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

