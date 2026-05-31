abstract final class AppConfig {
  static const String appName = 'Fresh Market';
  static const String appVersion = '1.0.0+1';

  static const String defaultCurrency = 'SAR';
  static const String defaultLocale = 'en';
  static const List<String> supportedLocales = ['en', 'ar'];

  static const int connectTimeout = 10000;
  static const int receiveTimeout = 15000;

  static const int pageSizeMobile = 20;
  static const int pageSizeDesktop = 50;

  static const bool enableLogging = true;
  static const bool enableCrashlytics = true;

  static const String firestoreCacheSize = '100MB';
}
