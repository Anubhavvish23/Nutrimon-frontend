import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'skeleton_fade_switcher.dart';

class SkeletonAsyncBuilder<T> extends StatelessWidget {
  final AsyncValue<T> async_value;
  final Widget skeleton;
  final Widget Function(T data) builder;
  final Widget Function(Object error, StackTrace stack)? error_builder;
  final Duration fade_duration;

  const SkeletonAsyncBuilder({
    super.key,
    required this.async_value,
    required this.skeleton,
    required this.builder,
    this.error_builder,
    this.fade_duration = const Duration(milliseconds: 350),
  });

  @override
  Widget build(BuildContext context) {
    return async_value.when(
      skipLoadingOnReload: true,
      skipLoadingOnRefresh: true,
      loading: () => skeleton,
      error: (error, stack) {
        if (error_builder != null) {
          return error_builder!(error, stack);
        }
        return Center(
          child: Text(
            'Something went wrong',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        );
      },
      data: (data) => builder(data),
    );
  }
}

class SkeletonLoadingBuilder extends StatelessWidget {
  final bool is_loading;
  final Widget skeleton;
  final Widget child;
  final Duration fade_duration;

  const SkeletonLoadingBuilder({
    super.key,
    required this.is_loading,
    required this.skeleton,
    required this.child,
    this.fade_duration = const Duration(milliseconds: 350),
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonFadeSwitcher(
      is_loading: is_loading,
      duration: fade_duration,
      skeleton: skeleton,
      child: child,
    );
  }
}
