import 'package:flutter/material.dart';
import '../config/app_brand.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _scale_controller;
  late AnimationController _glow_controller;
  late AnimationController _text_controller;
  late AnimationController _tagline_controller;

  late Animation<double> _scale_animation;
  late Animation<double> _glow_animation;
  late Animation<double> _text_opacity;
  late Animation<double> _tagline_opacity;
  late Animation<Offset> _tagline_slide;

  @override
  void initState() {
    super.initState();

    _scale_controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scale_animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scale_controller, curve: Curves.elasticOut),
    );

    _glow_controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _glow_animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glow_controller, curve: Curves.easeInOut),
    );

    _text_controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _text_opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _text_controller, curve: Curves.easeIn),
    );

    _tagline_controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _tagline_opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _tagline_controller, curve: Curves.easeIn),
    );
    _tagline_slide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _tagline_controller, curve: Curves.easeOut),
    );

    _startAnimations();
  }

  Future<void> _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _scale_controller.forward();

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    _text_controller.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _tagline_controller.forward();
  }

  @override
  void dispose() {
    _scale_controller.dispose();
    _glow_controller.dispose();
    _text_controller.dispose();
    _tagline_controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _glow_animation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1DB954)
                            .withOpacity(_glow_animation.value * 0.6),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                      BoxShadow(
                        color: const Color(0xFF1DB954)
                            .withOpacity(_glow_animation.value * 0.3),
                        blurRadius: 80,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                  child: child,
                );
              },
              child: ScaleTransition(
                scale: _scale_animation,
                child: Image.asset(
                  'assets/icon/icon.png',
                  width: 120,
                  height: 120,
                  errorBuilder: (context, error, stack_trace) {
                    return const Text('🌿', style: TextStyle(fontSize: 80));
                  },
                ),
              ),
            ),
            const SizedBox(height: 28),
            FadeTransition(
              opacity: _text_opacity,
              child: Text(
                AppBrand.name,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SlideTransition(
              position: _tagline_slide,
              child: FadeTransition(
                opacity: _tagline_opacity,
                child: Text(
                  '${AppBrand.tagline} 🌿',
                  style: TextStyle(
                    color: Color(0xFF1DB954),
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 80),
            FadeTransition(
              opacity: _tagline_opacity,
              child: _buildLoadingDots(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingDots() {
    return AnimatedBuilder(
      animation: _glow_controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final delay = i * 0.3;
            final value =
                ((_glow_controller.value - delay) % 1.0).clamp(0.0, 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1DB954).withOpacity(value),
              ),
            );
          }),
        );
      },
    );
  }
}
