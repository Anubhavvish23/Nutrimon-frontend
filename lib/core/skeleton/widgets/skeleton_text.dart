import 'package:flutter/material.dart';
import '../skeleton_colors.dart';
import 'skeleton_box.dart';

class SkeletonText extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius? border_radius;
  final SkeletonAnimationType animation_type;

  const SkeletonText({
    super.key,
    this.width,
    this.height = 14,
    this.border_radius,
    this.animation_type = SkeletonAnimationType.shimmer,
  });

  const SkeletonText.title({
    super.key,
    this.width,
    this.animation_type = SkeletonAnimationType.shimmer,
  })  : height = 22,
        border_radius = null;

  const SkeletonText.caption({
    super.key,
    this.width,
    this.animation_type = SkeletonAnimationType.shimmer,
  })  : height = 12,
        border_radius = null;

  @override
  Widget build(BuildContext context) {
    final effective_width = width ??
        (MediaQuery.sizeOf(context).width * 0.4).clamp(80.0, 200.0);

    return SkeletonBox(
      width: effective_width,
      height: height,
      border_radius: border_radius ?? BorderRadius.circular(height / 2),
      animation_type: animation_type,
    );
  }
}

class SkeletonTextBlock extends StatelessWidget {
  final int lines;
  final double line_height;
  final double spacing;
  final double? last_line_width_factor;
  final SkeletonAnimationType animation_type;

  const SkeletonTextBlock({
    super.key,
    this.lines = 3,
    this.line_height = 14,
    this.spacing = 8,
    this.last_line_width_factor = 0.6,
    this.animation_type = SkeletonAnimationType.shimmer,
  });

  @override
  Widget build(BuildContext context) {
    final screen_width = MediaQuery.sizeOf(context).width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(lines, (index) {
        final is_last = index == lines - 1;
        final line_width = is_last && last_line_width_factor != null
            ? screen_width * last_line_width_factor!
            : null;

        return Padding(
          padding: EdgeInsets.only(bottom: index < lines - 1 ? spacing : 0),
          child: SkeletonText(
            width: line_width,
            height: line_height,
            animation_type: animation_type,
          ),
        );
      }),
    );
  }
}
