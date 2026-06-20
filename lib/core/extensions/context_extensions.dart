import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_market/l10n/app_localizations.dart';
import 'package:fresh_market/presentation/features/settings/providers/settings_provider.dart';

extension ContextExtensions on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  String formatPrice(double price) {
    final priceStr = price % 1 == 0 ? price.toInt().toString() : price.toStringAsFixed(2);
    try {
      final settings = ProviderScope.containerOf(this, listen: false).read(settingsProvider);
      final locale = Localizations.localeOf(this).languageCode;
      if (locale == 'ar') {
        if (settings.currencyCode == 'EGP') {
          return '$priceStr جنيه مصري';
        }
        return '$priceStr ${settings.currencySymbol}';
      } else if (locale == 'en') {
        return '$priceStr ${settings.currencyCode}';
      } else {
        return '$priceStr ${settings.currencySymbol}';
      }
    } catch (_) {
      final locale = Localizations.localeOf(this).languageCode;
      if (locale == 'ar') {
        return '$priceStr جنيه مصري';
      } else if (locale == 'en') {
        return '$priceStr EGP';
      } else {
        return '$priceStr E£';
      }
    }
  }


  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;

  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => mediaQuery.size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;

  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1024;
  bool get isDesktop => screenWidth >= 1024;

  TextDirection get textDirection => Directionality.of(this);
  bool get isRtl => textDirection == TextDirection.rtl;

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : null,
      ),
    );
  }
}
