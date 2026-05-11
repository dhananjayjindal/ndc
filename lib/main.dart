import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_logger.dart';
import 'cart.dart';
import 'loading_screen.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // ─────────────────────────────────────────────
      // FLUTTER FRAMEWORK ERRORS
      // ─────────────────────────────────────────────

      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);

        AppLogger.e(
          'FLUTTER FRAMEWORK ERROR',
          details.exception,
          details.stack,
        );
      };

      // ─────────────────────────────────────────────
      // PLATFORM ERRORS
      // ─────────────────────────────────────────────

      PlatformDispatcher.instance.onError = (error, stack) {
        AppLogger.e('PLATFORM ERROR', error, stack);

        return true;
      };

      AppLogger.i('🚀 App Starting...');

      // ─────────────────────────────────────────────
      // LOAD CART
      // ─────────────────────────────────────────────

      final cart = Cart();

      try {
        await cart.loadFromPrefs();

        AppLogger.s('🛒 Cart Loaded Successfully');
      } catch (e, stack) {
        AppLogger.e('❌ Failed To Load Cart', e, stack);
      }

      // ─────────────────────────────────────────────
      // RUN APP
      // ─────────────────────────────────────────────

      runApp(
        ChangeNotifierProvider<Cart>.value(value: cart, child: const MyApp()),
      );
    },

    // ─────────────────────────────────────────────
    // UNCAUGHT DART ERRORS
    // ─────────────────────────────────────────────
    (error, stack) {
      AppLogger.e('UNCAUGHT DART ERROR', error, stack);
    },
  );
}

// ─────────────────────────────────────────────
// ROOT APP
// ─────────────────────────────────────────────

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // ─────────────────────────────────────────────
  // RESPONSIVE HELPERS
  // ─────────────────────────────────────────────

  static bool isWeb(BuildContext context) {
    return MediaQuery.of(context).size.width >= 700;
  }

  static bool isPhone(BuildContext context) {
    return MediaQuery.of(context).size.width <= 700;
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Nav Durga Collection',

      // ─────────────────────────────────────────────
      // THEME
      // ─────────────────────────────────────────────
      theme: ThemeData(
        useMaterial3: true,

        brightness: Brightness.dark,

        scaffoldBackgroundColor: const Color(0xFF0D1015),

        splashFactory: InkRipple.splashFactory,

        fontFamily: 'Roboto',

        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          secondary: Color(0xFF7C4DFF),
          surface: Color(0xFF12161C),
        ),

        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
        ),

        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Colors.white,
        ),

        dividerColor: Colors.white12,
      ),

      // ─────────────────────────────────────────────
      // BUILDER
      // ─────────────────────────────────────────────
      builder: (context, child) {
        final web = isWeb(context);

        if (kDebugMode) {
          AppLogger.d('📱 Running on ${web ? "WEB" : "PHONE"}');
        }

        // REMOVE TEXT SCALE BREAKING UI
        final media = MediaQuery.of(context);

        return MediaQuery(
          data: media.copyWith(
            textScaler: TextScaler.linear(
              media.textScaler.scale(1).clamp(0.85, 1.05),
            ),
          ),

          child: child ?? const SizedBox(),
        );
      },

      // ─────────────────────────────────────────────
      // HOME
      // ─────────────────────────────────────────────
      home: const LoadingScreen(),
    );
  }
}
