import 'package:flutter/material.dart';
import '../../../core/theme/app_theme_extension.dart';

class AuthGoogleButton extends StatelessWidget {
  const AuthGoogleButton({
    super.key,
    required this.label,
    required this.on_pressed,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? on_pressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final app = context.app;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: enabled ? on_pressed : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: app.accent,
          side: BorderSide(color: app.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'G',
                style: TextStyle(
                  color: Color(0xFF4285F4),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthSwitchLink extends StatelessWidget {
  const AuthSwitchLink({
    super.key,
    required this.prompt,
    required this.action_label,
    required this.on_action,
  });

  final String prompt;
  final String action_label;
  final VoidCallback on_action;

  @override
  Widget build(BuildContext context) {
    final app = context.app;

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      runSpacing: 4,
      children: [
        Text(prompt, style: TextStyle(color: app.text_muted)),
        GestureDetector(
          onTap: on_action,
          child: Text(
            action_label,
            style: TextStyle(
              color: app.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
