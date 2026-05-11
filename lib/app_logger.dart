import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  // ─────────────────────────────────────────────
  // COLORS
  // ─────────────────────────────────────────────

  static const String _reset = '\x1B[0m';

  static const String _red = '\x1B[31m';

  static const String _green = '\x1B[32m';

  static const String _yellow = '\x1B[33m';

  static const String _cyan = '\x1B[36m';

  static const String _magenta = '\x1B[35m';

  static const String _blue = '\x1B[34m';

  // ─────────────────────────────────────────────
  // ENABLE / DISABLE LOGGING
  // ─────────────────────────────────────────────

  static const bool enableLogs = kDebugMode;

  // ─────────────────────────────────────────────
  // CORE LOGGER
  // ─────────────────────────────────────────────

  static void _log(
    String level,
    String message,
    String color, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    // 🚫 NO LOGS IN RELEASE
    if (!enableLogs) {
      return;
    }

    try {
      final now = DateTime.now();

      final time =
          '${now.hour.toString().padLeft(2, '0')}:'
          '${now.minute.toString().padLeft(2, '0')}:'
          '${now.second.toString().padLeft(2, '0')}';

      final prefix = '$color[$time] $level$_reset';

      // MAIN MESSAGE
      debugPrint('$prefix $message');

      // ERROR
      if (error != null) {
        debugPrint('$color  ┗━ ❌ Error: $error$_reset');
      }

      // STACKTRACE
      if (stackTrace != null) {
        debugPrint(
          '$color  ┗━ 📜 StackTrace:\n'
          '$stackTrace$_reset',
        );
      }
    } catch (_) {
      // Prevent logger crashes
    }
  }

  // ─────────────────────────────────────────────
  // INFO
  // ─────────────────────────────────────────────

  static void i(String message) {
    _log('ℹ️ INFO', message, _blue);
  }

  // ─────────────────────────────────────────────
  // DEBUG
  // ─────────────────────────────────────────────

  static void d(String message) {
    _log('🐞 DEBUG', message, _cyan);
  }

  // ─────────────────────────────────────────────
  // SUCCESS
  // ─────────────────────────────────────────────

  static void s(String message) {
    _log('✅ SUCCESS', message, _green);
  }

  // ─────────────────────────────────────────────
  // WARNING
  // ─────────────────────────────────────────────

  static void w(String message) {
    _log('⚠️ WARNING', message, _yellow);
  }

  // ─────────────────────────────────────────────
  // ERROR
  // ─────────────────────────────────────────────

  static void e(String message, [Object? error, StackTrace? stackTrace]) {
    _log('❌ ERROR', message, _red, error: error, stackTrace: stackTrace);
  }

  // ─────────────────────────────────────────────
  // DIVIDER
  // ─────────────────────────────────────────────

  static void line([String label = '']) {
    if (!enableLogs) {
      return;
    }

    final divider = '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';

    debugPrint(
      '$_magenta$divider '
      '$label '
      '$divider$_reset',
    );
  }
}
