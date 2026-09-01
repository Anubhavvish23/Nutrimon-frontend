import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../config/app_assets.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool prefer_svg;

  const AppLogo({
    super.key,
    required this.size,
    this.prefer_svg = true,
  });

  @override
  Widget build(BuildContext context) {
    if (prefer_svg) {
      return SvgPicture.asset(
        AppAssets.logo_svg,
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
    }

    return Image.asset(
      AppAssets.logo_png,
      width: size,
      height: size,
      fit: BoxFit.contain,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) =>
          const Text('🌿', style: TextStyle(fontSize: 48)),
    );
  }
}
