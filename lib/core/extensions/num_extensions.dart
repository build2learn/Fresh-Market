import 'package:intl/intl.dart';

extension NumExtensions on num {
  String formatPrice({String locale = 'en', String? currencySymbol}) {
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: currencySymbol ?? (locale == 'ar' ? 'ر.س' : 'SAR'),
      decimalDigits: 2,
    );
    return formatter.format(this);
  }

  String formatWeight({String locale = 'en'}) {
    final formatter = NumberFormat(
      locale == 'ar' ? '#,##0.###' : '#,##0.###',
      locale,
    );
    return formatter.format(this);
  }
}
