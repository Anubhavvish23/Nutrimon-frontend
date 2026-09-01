import 'package:flutter/material.dart';
import '../skeleton_colors.dart';
import 'skeleton_box.dart';

class SkeletonImage extends StatelessWidget {
  final double? width;
  final double? height;
  final double? aspect_ratio;
  final BorderRadius? border_radius;
  final SkeletonAnimationType animation_type;

  const SkeletonImage({
    super.key,
    this.width,
    this.height,
    this.aspect_ratio,
    this.border_radius,
    this.animation_type = SkeletonAnimationType.shimmer,
  });

  const SkeletonImage.square({
    super.key,
    double? size,
    this.border_radius,
    this.animation_type = SkeletonAnimationType.shimmer,
  })  : width = size,
        height = size,
        aspect_ratio = null;

  @override
  Widget build(BuildContext context) {
    final resolved_radius = border_radius ?? BorderRadius.circular(12);

    if (aspect_ratio != null) {
      return AspectRatio(
        aspectRatio: aspect_ratio!,
        child: SkeletonBox(
          width: width,
          height: height,
          border_radius: resolved_radius,
          animation_type: animation_type,
        ),
      );
    }

    return SkeletonBox(
      width: width,
      height: height,
      border_radius: resolved_radius,
      animation_type: animation_type,
    );
  }
}
