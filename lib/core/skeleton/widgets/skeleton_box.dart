import 'package:flutter/material.dart';
import '../skeleton_colors.dart';
import 'skeleton_shimmer.dart';

class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? border_radius;
  final SkeletonAnimationType animation_type;
  final SkeletonColors? colors;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.border_radius,
    this.animation_type = SkeletonAnimationType.shimmer,
    this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final skeleton_colors = colors ?? SkeletonColors.of(context);
    final resolved_radius = border_radius ?? BorderRadius.circular(8);

    return SkeletonShimmer(
      animation_type: animation_type,
      colors: skeleton_colors,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: skeleton_colors.base,
          borderRadius: resolved_radius,
        ),
      ),
    );
  }
}
