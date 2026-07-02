import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';

/// Responsive breakpoint helper
enum ScreenType { mobile, tablet, desktop }

class ResponsiveHelper {
  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < AppSpacing.breakpointMobile) return ScreenType.mobile;
    if (width < AppSpacing.breakpointTablet) return ScreenType.tablet;
    return ScreenType.desktop;
  }

  static bool isMobile(BuildContext context) =>
      getScreenType(context) == ScreenType.mobile;

  static bool isTablet(BuildContext context) =>
      getScreenType(context) == ScreenType.tablet;

  static bool isDesktop(BuildContext context) =>
      getScreenType(context) == ScreenType.desktop;

  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static int gridCrossAxisCount(BuildContext context) {
    final type = getScreenType(context);
    switch (type) {
      case ScreenType.mobile:
        return 1;
      case ScreenType.tablet:
        return 2;
      case ScreenType.desktop:
        return 3;
    }
  }
}
