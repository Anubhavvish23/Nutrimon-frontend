import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme_extension.dart';
import 'terms_and_conditions_sheet.dart';

class TermsAcceptanceCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> on_changed;

  const TermsAcceptanceCheckbox({
    super.key,
    required this.value,
    required this.on_changed,
  });

  @override
  State<TermsAcceptanceCheckbox> createState() =>
      _TermsAcceptanceCheckboxState();
}

class _TermsAcceptanceCheckboxState extends State<TermsAcceptanceCheckbox> {
  bool _reading = false;
  TapGestureRecognizer? _terms_recognizer;

  @override
  void initState() {
    super.initState();
    _terms_recognizer = TapGestureRecognizer()..onTap = _open_terms;
  }

  @override
  void dispose() {
    _terms_recognizer?.dispose();
    super.dispose();
  }

  Future<void> _open_terms() async {
    if (_reading) return;
    setState(() => _reading = true);
    await showTermsAndConditionsSheet(context);
    if (mounted) setState(() => _reading = false);
  }

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
            value: widget.value,
            onChanged: (checked) => widget.on_changed(checked ?? false),
            activeColor: app.accent,
            side: BorderSide(color: app.border),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () => widget.on_changed(!widget.value),
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
                    text: _reading ? 'Loading terms…' : 'Terms & Conditions',
                    style: TextStyle(
                      color: app.accent,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: _terms_recognizer,
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
