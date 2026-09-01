import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../errors/app_error_kind.dart';
import '../providers/connectivity_provider.dart';
import 'error/app_error_screen.dart';

class ConnectivityGate extends ConsumerWidget {
  final Widget child;

  const ConnectivityGate({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final is_online = ref.watch(isOnlineProvider);

    return Stack(
      children: [
        child,
        if (!is_online)
          Positioned.fill(
            child: AppErrorScreen(
              kind: AppErrorKind.offline,
              show_back_button: false,
              on_retry: () => ref.read(isOnlineProvider.notifier).refresh(),
            ),
          ),
      ],
    );
  }
}
