import 'package:flutter/material.dart';

class SkeletonResponsive {
  static const double tablet_breakpoint = 600;

  static bool isTablet(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= tablet_breakpoint;
  }

  static int gridCrossAxisCount(BuildContext context, {int mobile = 2, int tablet = 3}) {
    return isTablet(context) ? tablet : mobile;
  }

  static double horizontalPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 900) return 48;
    if (width >= tablet_breakpoint) return 32;
    return 20;
  }

  static double maxContentWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 900) return 800;
    if (width >= tablet_breakpoint) return 680;
    return width;
  }
}
