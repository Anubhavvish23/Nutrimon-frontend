import 'package:flutter/material.dart';

class SkeletonStaggeredList extends StatefulWidget {
  final int item_count;
  final Widget Function(BuildContext context, int index) item_builder;
  final Duration stagger_delay;
  final Duration item_duration;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;

  const SkeletonStaggeredList({
    super.key,
    required this.item_count,
    required this.item_builder,
    this.stagger_delay = const Duration(milliseconds: 80),
    this.item_duration = const Duration(milliseconds: 400),
    this.physics,
    this.padding,
  });

  @override
  State<SkeletonStaggeredList> createState() => _SkeletonStaggeredListState();
}

class _SkeletonStaggeredListState extends State<SkeletonStaggeredList>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startStagger();
  }

  void _initAnimations() {
    _controllers = List.generate(
      widget.item_count,
      (_) => AnimationController(
        vsync: this,
        duration: widget.item_duration,
      ),
    );
    _animations = _controllers
        .map(
          (controller) => CurvedAnimation(
            parent: controller,
            curve: Curves.easeOut,
          ),
        )
        .toList();
  }

  Future<void> _startStagger() async {
    for (var i = 0; i < _controllers.length; i++) {
      if (!mounted) return;
      _controllers[i].forward();
      await Future.delayed(widget.stagger_delay);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: widget.physics,
      padding: widget.padding,
      itemCount: widget.item_count,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 16 * (1 - _animations[index].value)),
              child: Opacity(
                opacity: _animations[index].value,
                child: child,
              ),
            );
          },
          child: widget.item_builder(context, index),
        );
      },
    );
  }
}
