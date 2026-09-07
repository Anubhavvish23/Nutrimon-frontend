import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../providers/terms_acceptance_provider.dart';
import 'terms_and_conditions_sheet.dart';

Future<void> showPostLoginTermsDialog(BuildContext context, WidgetRef ref) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialog_context) {
      return _PostLoginTermsDialog(ref: ref);
    },
  );
}

class _PostLoginTermsDialog extends StatefulWidget {
  final WidgetRef ref;

  const _PostLoginTermsDialog({required this.ref});

  @override
  State<_PostLoginTermsDialog> createState() => _PostLoginTermsDialogState();
}

class _PostLoginTermsDialogState extends State<_PostLoginTermsDialog> {
  bool _reading = false;
  bool _accepting = false;

  Future<void> _open_terms() async {
    if (_reading) return;
    setState(() => _reading = true);
    await showTermsAndConditionsSheet(context);
    if (mounted) setState(() => _reading = false);
  }

  Future<void> _accept() async {
    if (_accepting) return;
    setState(() => _accepting = true);
    await widget.ref.read(termsAcceptedProvider.notifier).mark_accepted();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final on_surface = context.on_surface;

    return PopScope(
      canPop: false,
      child: AlertDialog(
        backgroundColor: app.surface,
        title: Text(
          'Terms & Conditions',
          style: TextStyle(color: on_surface, fontWeight: FontWeight.w700),
        ),
        content: SingleChildScrollView(
          child: Text(
            'Please read and accept our Terms & Conditions to use NutriMorning. '
            'AI recommendations are not medical advice and may be inaccurate.',
            style: TextStyle(color: app.text_muted, height: 1.45),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _reading ? null : _open_terms,
            child: _reading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF1DB954),
                    ),
                  )
                : Text('Read full terms', style: TextStyle(color: app.accent)),
          ),
          ElevatedButton(
            onPressed: _accepting ? null : _accept,
            child: _accepting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('I agree'),
          ),
        ],
      ),
    );
  }
}
