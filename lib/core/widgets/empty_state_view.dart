import 'package:flutter/material.dart';

class EmptyStateView extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final String? action_label;
  final VoidCallback? on_action;
  final String? secondary_action_label;
  final VoidCallback? on_secondary_action;

  const EmptyStateView({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.action_label,
    this.on_action,
    this.secondary_action_label,
    this.on_secondary_action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 40)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF888888),
                fontSize: 14,
                height: 1.45,
              ),
            ),
            if (action_label != null && on_action != null) ...[
              const SizedBox(height: 28),
              _actionChip(
                label: action_label!,
                filled: true,
                onTap: on_action!,
              ),
            ],
            if (secondary_action_label != null && on_secondary_action != null) ...[
              const SizedBox(height: 12),
              _actionChip(
                label: secondary_action_label!,
                filled: false,
                onTap: on_secondary_action!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _actionChip({
    required String label,
    required bool filled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: filled ? const Color(0xFF1DB954) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: filled
              ? null
              : Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: filled ? Colors.white : const Color(0xFFAAAAAA),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
