enum Flavor { development, staging, production }

abstract final class EnvConfig {
  static Flavor _flavor = Flavor.development;

  static Flavor get flavor => _flavor;

  static void init(Flavor flavor) {
    _flavor = flavor;
  }

  static String get appName {
    return switch (_flavor) {
      Flavor.development => 'Fresh Market Dev',
      Flavor.staging => 'Fresh Market Staging',
      Flavor.production => 'Fresh Market',
    };
  }

  static bool get useEmulator => _flavor == Flavor.development;

  static bool get enableCrashlytics => _flavor == Flavor.production;

  static bool get enableAnalytics => _flavor != Flavor.development;

  static String get logLevel {
    return switch (_flavor) {
      Flavor.development => 'debug',
      Flavor.staging => 'info',
      Flavor.production => 'warning',
    };
  }
}
