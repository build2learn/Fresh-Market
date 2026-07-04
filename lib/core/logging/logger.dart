import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Enterprise logging helper wrapper for Fresh Market
class AppLogger {
  AppLogger._();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,       // Number of method calls to be displayed
      errorMethodCount: 8,  // Number of method calls if stacktrace is provided
      lineLength: 120,      // Width of the output
      colors: true,         // Colorful log messages
      printEmojis: true,    // Print an emoji for each log message
      printTime: true,      // Should each log print contain a timestamp
    ),
  );

  /// Log a message at the verbose/debug level.
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Log a message at the info level.
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Log a message at the warning level.
  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Log a message at the error level.
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
    
    // In production, also forward critical errors to Firebase Crashlytics
    if (!kDebugMode) {
      try {
        // FirebaseCrashlytics.instance.recordError(error ?? message, stackTrace);
      } catch (_) {}
    }
  }
}
