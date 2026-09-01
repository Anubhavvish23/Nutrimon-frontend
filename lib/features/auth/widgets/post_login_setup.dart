import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../providers/terms_acceptance_provider.dart';
import 'terms_and_conditions_sheet.dart';

Future<void> showPostLoginTermsDialog(BuildContext context, WidgetRef ref) {
  final app = context.app;
  final on_surface = context.on_surface;

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialog_context) {
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
              onPressed: () => showTermsAndConditionsSheet(dialog_context),
              child: Text('Read full terms', style: TextStyle(color: app.accent)),
            ),
            ElevatedButton(
              onPressed: () async {
                await ref.read(termsAcceptedProvider.notifier).mark_accepted();
                if (dialog_context.mounted) {
                  Navigator.of(dialog_context).pop();
                }
              },
              child: const Text('I agree'),
            ),
          ],
        ),
      );
    },
  );
}
