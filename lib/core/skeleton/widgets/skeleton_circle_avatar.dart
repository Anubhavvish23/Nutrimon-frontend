import 'package:flutter/material.dart';
import '../skeleton_colors.dart';
import 'skeleton_box.dart';

class SkeletonCircleAvatar extends StatelessWidget {
  final double? radius;
  final SkeletonAnimationType animation_type;

  const SkeletonCircleAvatar({
    super.key,
    this.radius,
    this.animation_type = SkeletonAnimationType.shimmer,
  });

  @override
  Widget build(BuildContext context) {
    final effective_radius = radius ?? 24;
    final size = effective_radius * 2;

    return SkeletonBox(
      width: size,
      height: size,
      border_radius: BorderRadius.circular(size / 2),
      animation_type: animation_type,
    );
  }
}
