import 'package:flutter/material.dart';

class SkeletonFadeSwitcher extends StatelessWidget {
  final bool is_loading;
  final Widget skeleton;
  final Widget child;
  final Duration duration;
  final Curve curve;

  const SkeletonFadeSwitcher({
    super.key,
    required this.is_loading,
    required this.skeleton,
    required this.child,
    this.duration = const Duration(milliseconds: 350),
    this.curve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: curve,
      switchOutCurve: curve,
      layoutBuilder: (current_child, previous_children) {
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            ...previous_children,
            if (current_child != null) current_child,
          ],
        );
      },
      transitionBuilder: (widget, animation) {
        return FadeTransition(
          opacity: animation,
          child: widget,
        );
      },
      child: is_loading
          ? KeyedSubtree(
              key: const ValueKey('skeleton'),
              child: skeleton,
            )
          : KeyedSubtree(
              key: const ValueKey('content'),
              child: child,
            ),
    );
  }
}
