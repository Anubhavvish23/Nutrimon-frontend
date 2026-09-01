import 'package:flutter/material.dart';

enum SkeletonAnimationType { shimmer, pulse }

class SkeletonColors {
  final Color base;
  final Color highlight;

  const SkeletonColors({
    required this.base,
    required this.highlight,
  });

  static SkeletonColors of(BuildContext context) {
  final is_dark = Theme.of(context).brightness == Brightness.dark;
    return is_dark ? dark : light;
  }

  static const SkeletonColors light = SkeletonColors(
    base: Color(0xFFE8E8E8),
    highlight: Color(0xFFF5F5F5),
  );

  static const SkeletonColors dark = SkeletonColors(
    base: Color(0xFF2A2A2A),
    highlight: Color(0xFF3A3A3A),
  );
}
