import 'package:flutter/material.dart';
import '../theme/app_theme_extension.dart';

class HalfScreenSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    double height_factor = 0.7,
    bool is_dismissible = true,
    bool enable_drag = true,
    Color? background_color,
    Color? barrier_color,
  }) {
    final app = context.app;
    final sheet_color = background_color ?? app.surface;

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: is_dismissible,
      enableDrag: enable_drag,
      backgroundColor: Colors.transparent,
      barrierColor: barrier_color ?? Colors.black54,
      builder: (context) {
        final sheet_app = context.app;
        return DraggableScrollableSheet(
          initialChildSize: height_factor,
          minChildSize: 0.4,
          maxChildSize: 0.92,
          expand: false,
          builder: (context, scroll_controller) {
            return Container(
              decoration: BoxDecoration(
                color: sheet_color,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                border: Border.all(color: sheet_app.border),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: sheet_app.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: HalfScreenSheetContent(
                      scroll_controller: scroll_controller,
                      child: child,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class HalfScreenSheetContent extends StatelessWidget {
  final ScrollController scroll_controller;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const HalfScreenSheetContent({
    super.key,
    required this.scroll_controller,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scroll_controller,
      padding: padding ?? const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: child,
    );
  }
}
