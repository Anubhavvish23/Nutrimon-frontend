import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/app_update_service.dart';
import '../theme/app_theme_extension.dart';

Future<void> showAppUpdateDialog(
  BuildContext context,
  AppUpdateInfo update,
) async {
  final app = context.app;
  final on_surface = context.on_surface;

  await showDialog<void>(
    context: context,
    barrierDismissible: !update.force_update,
    builder: (dialog_context) {
      return PopScope(
        canPop: !update.force_update,
        child: AlertDialog(
          backgroundColor: app.surface,
          title: Text(
            'Update available',
            style: TextStyle(color: on_surface, fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Version ${update.latest_version} is ready to install.',
                style: TextStyle(color: on_surface, height: 1.4),
              ),
              if (update.message.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  update.message,
                  style: TextStyle(color: app.text_muted, height: 1.4),
                ),
              ],
            ],
          ),
          actions: [
            if (!update.force_update)
              TextButton(
                onPressed: () async {
                  await AppUpdateService.dismiss_update(update.build_number);
                  if (dialog_context.mounted) {
                    Navigator.of(dialog_context).pop();
                  }
                },
                child: const Text('Later'),
              ),
            ElevatedButton(
              onPressed: () async {
                final url = AppUpdateService.resolve_apk_url(update.apk_url);
                final uri = Uri.parse(url);
                await launchUrl(uri, mode: LaunchMode.externalApplication);
                if (!update.force_update && dialog_context.mounted) {
                  Navigator.of(dialog_context).pop();
                }
              },
              child: const Text('Download update'),
            ),
          ],
        ),
      );
    },
  );
}
