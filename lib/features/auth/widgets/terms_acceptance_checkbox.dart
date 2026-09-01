import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme_extension.dart';
import 'terms_and_conditions_sheet.dart';

class TermsAcceptanceCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> on_changed;

  const TermsAcceptanceCheckbox({
    super.key,
    required this.value,
    required this.on_changed,
  });

  @override
  Widget build(BuildContext context) {
    final app = context.app;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: value,
            onChanged: (checked) => on_changed(checked ?? false),
            activeColor: app.accent,
            side: BorderSide(color: app.border),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () => on_changed(!value),
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: app.text_muted,
                  fontSize: 13,
                  height: 1.45,
                ),
                children: [
                  const TextSpan(
                    text: 'I have read and agree to the ',
                  ),
                  TextSpan(
                    text: 'Terms & Conditions',
                    style: TextStyle(
                      color: app.accent,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => showTermsAndConditionsSheet(context),
                  ),
                  const TextSpan(
                    text:
                        ', including the AI disclaimer. I understand recommendations are not medical advice and may be inaccurate.',
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

bool terms_acceptance_required({
  required bool already_accepted,
  required bool checked,
}) {
  return !already_accepted && !checked;
}
