import 'package:flutter/material.dart';
import '../config/app_brand.dart';
import '../widgets/app_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logo_controller;
  late final AnimationController _pulse_controller;
  late final AnimationController _text_controller;

  late final Animation<double> _logo_scale;
  late final Animation<double> _pulse;
  late final Animation<double> _text_opacity;
  late final Animation<Offset> _text_slide;

  @override
  void initState() {
    super.initState();

    _logo_controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _logo_scale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _logo_controller, curve: Curves.easeOutBack),
    );

    _pulse_controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _pulse_controller, curve: Curves.easeInOut),
    );

    _text_controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _text_opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _text_controller, curve: Curves.easeOut),
    );
    _text_slide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _text_controller, curve: Curves.easeOutCubic),
    );

    _logo_controller.forward();
    Future.delayed(const Duration(milliseconds: 280), () {
      if (mounted) _text_controller.forward();
    });
  }

  @override
  void dispose() {
    _logo_controller.dispose();
    _pulse_controller.dispose();
    _text_controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final on_surface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulse,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1DB954)
                            .withValues(alpha: _pulse.value * 0.5),
                        blurRadius: 32 + (_pulse.value * 10),
                        spreadRadius: 4 + (_pulse.value * 6),
                      ),
                    ],
                  ),
                  child: child,
                );
              },
              child: ScaleTransition(
                scale: _logo_scale,
                child: const AppLogo(size: 96),
              ),
            ),
            const SizedBox(height: 28),
            SlideTransition(
              position: _text_slide,
              child: FadeTransition(
                opacity: _text_opacity,
                child: Column(
                  children: [
                    Text(
                      AppBrand.name,
                      style: TextStyle(
                        color: on_surface,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${AppBrand.tagline} 🌿',
                      style: const TextStyle(
                        color: Color(0xFF1DB954),
                        fontSize: 14,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),
            FadeTransition(
              opacity: _text_opacity,
              child: SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: const Color(0xFF1DB954).withValues(alpha: 0.85),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
