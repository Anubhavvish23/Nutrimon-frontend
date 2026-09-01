import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../skeleton_colors.dart';

class SkeletonShimmer extends StatelessWidget {
  final Widget child;
  final SkeletonAnimationType animation_type;
  final SkeletonColors? colors;

  const SkeletonShimmer({
    super.key,
    required this.child,
    this.animation_type = SkeletonAnimationType.shimmer,
    this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final skeleton_colors = colors ?? SkeletonColors.of(context);

    if (animation_type == SkeletonAnimationType.pulse) {
      return _PulseWrapper(
        base_color: skeleton_colors.base,
        highlight_color: skeleton_colors.highlight,
        child: child,
      );
    }

    return Shimmer.fromColors(
      baseColor: skeleton_colors.base,
      highlightColor: skeleton_colors.highlight,
      period: const Duration(milliseconds: 1200),
      child: child,
    );
  }
}

class _PulseWrapper extends StatefulWidget {
  final Widget child;
  final Color base_color;
  final Color highlight_color;

  const _PulseWrapper({
    required this.child,
    required this.base_color,
    required this.highlight_color,
  });

  @override
  State<_PulseWrapper> createState() => _PulseWrapperState();
}

class _PulseWrapperState extends State<_PulseWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ColorFiltered(
          colorFilter: ColorFilter.mode(
            Color.lerp(
              widget.base_color,
              widget.highlight_color,
              _animation.value,
            )!,
            BlendMode.srcATop,
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
