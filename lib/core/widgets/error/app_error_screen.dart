import 'package:flutter/material.dart';
import '../../errors/app_error_kind.dart';
import 'error_illustration.dart';

class AppErrorScreen extends StatelessWidget {
  final AppErrorKind kind;
  final String? message;
  final VoidCallback? on_retry;
  final VoidCallback? on_back;
  final bool show_back_button;

  const AppErrorScreen({
    super.key,
    required this.kind,
    this.message,
    this.on_retry,
    this.on_back,
    this.show_back_button = true,
  });

  @override
  Widget build(BuildContext context) {
    final scaffold_bg = Theme.of(context).scaffoldBackgroundColor;
    final on_surface = Theme.of(context).colorScheme.onSurface;

    return Material(
      color: scaffold_bg,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              if (show_back_button && on_back != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: on_back,
                  ),
                )
              else
                const SizedBox(height: 48),
              const Spacer(flex: 2),
              ErrorIllustration(kind: kind, size: 220),
              const SizedBox(height: 32),
              Text(
                kind.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: on_surface,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message ?? kind.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: on_surface.withOpacity(0.55),
                  fontSize: 15,
                  height: 1.45,
                ),
              ),
              const Spacer(flex: 3),
              if (on_retry != null)
                _actionButton(
                  label: 'Try again',
                  filled: true,
                  onTap: on_retry!,
                ),
              if (on_back != null && show_back_button) ...[
                const SizedBox(height: 12),
                _actionButton(
                  label: 'Go back',
                  filled: false,
                  onTap: on_back!,
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required bool filled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: filled ? const Color(0xFF1DB954) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: filled
              ? null
              : Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: filled ? Colors.white : const Color(0xFFAAAAAA),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

Future<void> showAppErrorScreen(
  BuildContext context, {
  required AppErrorKind kind,
  String? message,
  VoidCallback? on_retry,
}) {
  return Navigator.of(context).push<void>(
    PageRouteBuilder(
      opaque: true,
      pageBuilder: (_, __, ___) => AppErrorScreen(
        kind: kind,
        message: message,
        on_retry: on_retry == null
            ? null
            : () {
                Navigator.of(context).pop();
                on_retry();
              },
        on_back: () => Navigator.of(context).pop(),
      ),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  );
}
