import 'package:flutter/material.dart';
import '../config/app_assets.dart';

class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({
    super.key,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1DB954).withValues(alpha: 0.22),
            blurRadius: size * 0.2,
            spreadRadius: size * 0.02,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          AppAssets.logo_png,
          width: size,
          height: size,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (_, __, ___) => Container(
            width: size,
            height: size,
            color: const Color(0xFF0A0A0A),
            alignment: Alignment.center,
            child: const Text('🌿', style: TextStyle(fontSize: 28)),
          ),
        ),
      ),
    );
  }
}
