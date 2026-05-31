import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_market/l10n/app_localizations.dart';

import 'package:fresh_market/core/providers/locale_provider.dart';
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
    _initLocale();
  }

  Future<void> _initLocale() async {
    await ref.read(localeProvider.notifier).load();
    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final locale = ref.watch(localeProvider);
    final isArabic = locale.languageCode == 'ar';
    final router = ref.watch(goRouterProvider);

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
