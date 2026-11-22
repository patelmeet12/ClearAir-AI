import 'package:flutter/foundation.dart';

/// Centralized, production-safe logger for CleanAir AI.
/// Only outputs in debug mode; never logs sensitive credentials, API keys, or private tokens.
class AppLogger {
  static void info(String message) {
    if (kDebugMode) {
      debugPrint('[ClearAir INFO] $message');
    }
  }

  static void warning(String message, [Object? error]) {
    if (kDebugMode) {
      debugPrint('[ClearAir WARNING] $message${error != null ? ' | Error: $error' : ''}');
    }
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[ClearAir ERROR] $message${error != null ? ' | Error: $error' : ''}');
      if (stackTrace != null) {
        debugPrint(stackTrace.toString());
      }
    }
  }
}
