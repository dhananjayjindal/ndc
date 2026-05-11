import 'package:flutter/material.dart';
import 'package:ndc/home_page.dart';

import 'app_logger.dart';
import 'core/core.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  // ─────────────────────────────────────────────
  // ANIMATION
  // ─────────────────────────────────────────────

  late final AnimationController _controller;

  late final Animation<double> _fadeAnimation;

  // ─────────────────────────────────────────────
  // STATE
  // ─────────────────────────────────────────────

  bool _isLoading = true;

  String _loadingText = 'Preparing your experience...';

  // ─────────────────────────────────────────────
  // RESPONSIVE
  // ─────────────────────────────────────────────

  bool isWeb(BuildContext context) {
    return MediaQuery.of(context).size.width >= 700;
  }

  // ─────────────────────────────────────────────
  // INIT
  // ─────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  // ─────────────────────────────────────────────
  // INITIALIZE APP
  // ─────────────────────────────────────────────

  Future<void> _initializeApp() async {
    try {
      // Small visual delay for smoother UX
      await Future.delayed(const Duration(milliseconds: 3000));

      if (!mounted) return;

      setState(() {
        _loadingText = 'Loading products...';
      });

      // Start loading in background
      await ProductRepository.getProducts(); // Optional metadata warmup
      // fetchAppMetaDate();
      // fetchMobileNumber();

      if (!mounted) return;

      // Navigate immediately
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 400),

          reverseTransitionDuration: const Duration(milliseconds: 250),

          pageBuilder: (_, animation, secondaryAnimation) {
            return FadeTransition(opacity: animation, child: const HomePage());
          },

          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final fade = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            );

            return FadeTransition(opacity: fade, child: child);
          },
        ),
      );
    } catch (e, stack) {
      AppLogger.e('LoadingScreen Failed', e, stack);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,

          backgroundColor: Colors.red.shade400,

          content: const Text('Failed to initialize app'),
        ),
      );
    }
  }

  // ─────────────────────────────────────────────
  // DISPOSE
  // ─────────────────────────────────────────────

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final web = isWeb(context);

    final logoSize = web ? 150.0 : 120.0;

    final titleSize = web ? 22.0 : 18.0;

    final subtitleSize = web ? 14.0 : 12.5;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0D11),

      body: Stack(
        children: [
          // ─────────────────────────────────────────────
          // SOFT TOP GLOW
          // ─────────────────────────────────────────────
          Positioned(
            top: -80,
            left: -60,

            child: IgnorePointer(
              child: Container(
                width: 220,
                height: 220,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  gradient: RadialGradient(
                    colors: [
                      Colors.deepPurple.withValues(alpha: 0.14),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─────────────────────────────────────────────
          // BOTTOM GLOW
          // ─────────────────────────────────────────────
          Positioned(
            bottom: -100,
            right: -80,

            child: IgnorePointer(
              child: Container(
                width: 240,
                height: 240,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  gradient: RadialGradient(
                    colors: [
                      Colors.blue.withValues(alpha: 0.10),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─────────────────────────────────────────────
          // CONTENT
          // ─────────────────────────────────────────────
          SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,

                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),

                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),

                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        // ─────────────────────────────────────────────
                        // LOGO
                        // ─────────────────────────────────────────────
                        RepaintBoundary(
                          child: Container(
                            width: logoSize,
                            height: logoSize,

                            padding: const EdgeInsets.all(20),

                            decoration: BoxDecoration(
                              shape: BoxShape.circle,

                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,

                                colors: [
                                  Colors.white.withValues(alpha: 0.06),

                                  Colors.white.withValues(alpha: 0.02),
                                ],
                              ),

                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.04),
                              ),

                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 18,

                                  spreadRadius: -6,

                                  offset: const Offset(0, 10),

                                  color: Colors.black.withValues(alpha: 0.18),
                                ),
                              ],
                            ),

                            child: Image.asset(
                              AppImages.logo,

                              filterQuality: FilterQuality.low,
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // ─────────────────────────────────────────────
                        // TITLE
                        // ─────────────────────────────────────────────
                        Text(
                          'Nav Durga Collection',

                          textAlign: TextAlign.center,

                          style: TextStyle(
                            color: Colors.white,

                            fontSize: titleSize,

                            fontWeight: FontWeight.w800,

                            letterSpacing: -0.5,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // ─────────────────────────────────────────────
                        // SUBTITLE
                        // ─────────────────────────────────────────────
                        Text(
                          'Luxury fashion crafted for every moment.',

                          textAlign: TextAlign.center,

                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.65),

                            fontSize: subtitleSize,

                            fontWeight: FontWeight.w500,

                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 34),

                        // ─────────────────────────────────────────────
                        // LOADER
                        // ─────────────────────────────────────────────
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),

                          child: _isLoading
                              ? Row(
                                  key: const ValueKey('loading'),

                                  mainAxisAlignment: MainAxisAlignment.center,

                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,

                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2.4,
                                      ),
                                    ),

                                    const SizedBox(width: 14),

                                    Flexible(
                                      child: Text(
                                        _loadingText,

                                        overflow: TextOverflow.ellipsis,

                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.72,
                                          ),

                                          fontSize: web ? 14 : 12.5,

                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox.shrink(),
                        ),

                        const SizedBox(height: 70),

                        // ─────────────────────────────────────────────
                        // FOOTER
                        // ─────────────────────────────────────────────
                        Text(
                          'Powered by NDC',

                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.24),

                            fontSize: 11,

                            letterSpacing: 1.1,

                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
