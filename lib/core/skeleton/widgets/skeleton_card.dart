import 'package:flutter/material.dart';
import '../skeleton_colors.dart';
import 'skeleton_shimmer.dart';

class SkeletonCard extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  final double? height;
  final BorderRadius? border_radius;
  final SkeletonAnimationType animation_type;
  final Widget? child;

  const SkeletonCard({
    super.key,
    this.padding,
    this.height,
    this.border_radius,
    this.animation_type = SkeletonAnimationType.shimmer,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final skeleton_colors = SkeletonColors.of(context);
    final resolved_radius = border_radius ?? BorderRadius.circular(20);
    final resolved_padding = padding ?? const EdgeInsets.all(18);
    final screen_width = MediaQuery.sizeOf(context).width;

    return SkeletonShimmer(
      animation_type: animation_type,
      colors: skeleton_colors,
      child: Container(
        width: double.infinity,
        height: height,
        padding: resolved_padding,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: skeleton_colors.base,
          borderRadius: resolved_radius,
        ),
        child: child ??
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _bone(
                  width: screen_width * 0.35,
                  height: 12,
                  colors: skeleton_colors,
                ),
                const SizedBox(height: 12),
                _bone(
                  width: double.infinity,
                  height: 14,
                  colors: skeleton_colors,
                ),
                const SizedBox(height: 8),
                _bone(
                  width: screen_width * 0.6,
                  height: 14,
                  colors: skeleton_colors,
                ),
              ],
            ),
      ),
    );
  }

  Widget _bone({
    required double height,
    required SkeletonColors colors,
    double? width,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colors.highlight.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }
}
