import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme_extension.dart';

class ValueStepperPicker extends StatelessWidget {
  final num value;
  final num min;
  final num max;
  final num step;
  final String unit;
  final String emoji;
  final Color accent;
  final List<num> quick_values;
  final ValueChanged<num> on_changed;
  final int fraction_digits;

  const ValueStepperPicker({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.unit,
    required this.emoji,
    required this.accent,
    required this.quick_values,
    required this.on_changed,
    this.fraction_digits = 0,
  });

  String get _display_value {
    if (fraction_digits <= 0) return value.round().toString();
    return value.toStringAsFixed(fraction_digits);
  }

  void _adjust(num delta) {
    final next = (value + delta).clamp(min, max);
    if (next == value) return;
    HapticFeedback.selectionClick();
    on_changed(next);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final on_surface = context.on_surface;

    return Column(
      children: [
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 10),
            Text(
              _display_value,
              style: TextStyle(
                color: accent,
                fontSize: 72,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                unit,
                style: TextStyle(
                  color: app.text_muted,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _round_button(
              context,
              icon: Icons.remove,
              on_tap: () => _adjust(-step),
              enabled: value > min,
            ),
            const SizedBox(width: 20),
            Container(
              width: 120,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: app.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accent.withValues(alpha: 0.45)),
              ),
              alignment: Alignment.center,
              child: Text(
                '$_display_value $unit',
                style: TextStyle(
                  color: on_surface,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 20),
            _round_button(
              context,
              icon: Icons.add,
              on_tap: () => _adjust(step),
              enabled: value < max,
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Quick pick',
          style: TextStyle(
            color: app.text_muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: quick_values.map((pick) {
            final is_selected = pick == value;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                on_changed(pick.clamp(min, max));
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: is_selected
                      ? accent.withValues(alpha: 0.15)
                      : app.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: is_selected ? accent : app.border,
                    width: is_selected ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  fraction_digits <= 0
                      ? '${pick.round()}$unit'
                      : '${pick.toStringAsFixed(fraction_digits)}$unit',
                  style: TextStyle(
                    color: is_selected ? accent : on_surface,
                    fontWeight:
                        is_selected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _round_button(
    BuildContext context, {
    required IconData icon,
    required VoidCallback on_tap,
    required bool enabled,
  }) {
    final app = context.app;
    return Material(
      color: enabled ? accent.withValues(alpha: 0.12) : app.surface,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: enabled ? on_tap : null,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 52,
          height: 52,
          child: Icon(
            icon,
            color: enabled ? accent : app.text_muted.withValues(alpha: 0.5),
            size: 26,
          ),
        ),
      ),
    );
  }
}
