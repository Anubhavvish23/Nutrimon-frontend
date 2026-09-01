import 'package:flutter/material.dart';
import '../../../core/config/app_brand.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../data/terms_and_conditions.dart';

Future<void> showTermsAndConditionsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheet_context) {
      final app = sheet_context.app;
      final on_surface = Theme.of(sheet_context).colorScheme.onSurface;
      final max_height = MediaQuery.sizeOf(sheet_context).height * 0.88;

      return Container(
        height: max_height,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        decoration: BoxDecoration(
          color: app.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: app.border),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Terms & Conditions',
                          style: TextStyle(
                            color: on_surface,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '${AppBrand.name} · v${TermsAndConditions.version} · ${TermsAndConditions.last_updated}',
                          style: TextStyle(color: app.text_muted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(sheet_context).pop(),
                    icon: Icon(Icons.close, color: app.text_muted),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: app.border),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9500).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFFF9500).withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('⚠️', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'AI features may produce incorrect or incomplete information. '
                            'Always verify meals, ingredients, and health guidance before acting on them.',
                            style: TextStyle(
                              color: on_surface,
                              fontSize: 13,
                              height: 1.45,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    TermsAndConditions.intro,
                    style: TextStyle(
                      color: on_surface,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...TermsAndConditions.sections.map((section) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            section.title,
                            style: TextStyle(
                              color: on_surface,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            section.body,
                            style: TextStyle(
                              color: app.text_muted,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
