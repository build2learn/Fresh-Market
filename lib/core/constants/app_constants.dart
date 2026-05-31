class AppConstants {
  AppConstants._();

  static const String appName = 'Fresh Market';
  static const String appNameAr = 'السوق الطازج';

  static const int defaultPageSize = 20;
  static const int desktopPageSize = 50;
  static const int searchDebounceMillis = 300;
  static const int bannerAutoScrollSeconds = 4;

  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;

  static const int maxProductImages = 5;
  static const double maxImageSizeMb = 5;
  static const List<String> allowedImageFormats = ['jpeg', 'jpg', 'png', 'webp'];

  static const int cacheDurationSeconds = 30;
  static const int lookupCacheDurationSeconds = 300;
}
