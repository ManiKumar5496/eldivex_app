// lib/app/core/values/size_configue.dart
import 'package:flutter/material.dart';

import '../../modules/dashboard/views/side_menu_widget_view.dart';

/// Enhanced SizeConfig with Responsive Design System
/// Backward compatible with existing code + new professional responsive features
class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;

  // Store context for responsive features
  static BuildContext? _context;

  static void init(BuildContext context) {
    _context = context;
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;
  }

  // ================= DEVICE TYPE DETECTION =================

  static DeviceType get deviceType {
    if (screenWidth < 600) {
      return DeviceType.mobile;
    } else if (screenWidth < 1024) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  static bool get isMobile => deviceType == DeviceType.mobile;
  static bool get isTablet => deviceType == DeviceType.tablet;
  static bool get isDesktop => deviceType == DeviceType.desktop;

  // ================= SAFE AREA =================

  static double get safeAreaTop => _mediaQueryData.padding.top;
  static double get safeAreaBottom => _mediaQueryData.padding.bottom;

  // ================= ADAPTIVE SPACING =================

  /// Extra Small Spacing (4px mobile, 6px tablet, 8px desktop)
  static double get spacingXS {
    switch (deviceType) {
      case DeviceType.mobile:
        return 4;
      case DeviceType.tablet:
        return 6;
      case DeviceType.desktop:
        return 8;
    }
  }

  /// Small Spacing (8px mobile, 10px tablet, 12px desktop)
  static double get spacingSM {
    switch (deviceType) {
      case DeviceType.mobile:
        return 8;
      case DeviceType.tablet:
        return 10;
      case DeviceType.desktop:
        return 12;
    }
  }

  /// Medium Spacing (12px mobile, 16px tablet, 20px desktop)
  static double get spacingMD {
    switch (deviceType) {
      case DeviceType.mobile:
        return 12;
      case DeviceType.tablet:
        return 16;
      case DeviceType.desktop:
        return 20;
    }
  }

  /// Large Spacing (16px mobile, 20px tablet, 24px desktop)
  static double get spacingLG {
    switch (deviceType) {
      case DeviceType.mobile:
        return 16;
      case DeviceType.tablet:
        return 20;
      case DeviceType.desktop:
        return 24;
    }
  }

  /// Extra Large Spacing (20px mobile, 24px tablet, 32px desktop)
  static double get spacingXL {
    switch (deviceType) {
      case DeviceType.mobile:
        return 20;
      case DeviceType.tablet:
        return 24;
      case DeviceType.desktop:
        return 32;
    }
  }

  /// Section Spacing (24px mobile, 32px tablet, 40px desktop)
  static double get spacingSection {
    switch (deviceType) {
      case DeviceType.mobile:
        return 24;
      case DeviceType.tablet:
        return 32;
      case DeviceType.desktop:
        return 40;
    }
  }

  // ================= ADAPTIVE PADDING =================

  /// Page Padding (12px mobile, 16px tablet, 24px desktop)
  static EdgeInsets get pagePadding {
    switch (deviceType) {
      case DeviceType.mobile:
        return const EdgeInsets.all(12);
      case DeviceType.tablet:
        return const EdgeInsets.all(16);
      case DeviceType.desktop:
        return const EdgeInsets.all(24);
    }
  }

  /// Card Padding (12px mobile, 16px tablet, 20px desktop)
  static EdgeInsets get cardPadding {
    switch (deviceType) {
      case DeviceType.mobile:
        return const EdgeInsets.all(12);
      case DeviceType.tablet:
        return const EdgeInsets.all(16);
      case DeviceType.desktop:
        return const EdgeInsets.all(20);
    }
  }

  /// Button Padding
  static EdgeInsets get buttonPadding {
    switch (deviceType) {
      case DeviceType.mobile:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case DeviceType.tablet:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 14);
      case DeviceType.desktop:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
  }

  // ================= ADAPTIVE TYPOGRAPHY =================

  /// Display Text (24px mobile, 28px tablet, 32px desktop)
  static double get fontDisplay {
    switch (deviceType) {
      case DeviceType.mobile:
        return 24;
      case DeviceType.tablet:
        return 28;
      case DeviceType.desktop:
        return 32;
    }
  }

  /// Heading 1 (20px mobile, 22px tablet, 24px desktop)
  static double get fontH1 {
    switch (deviceType) {
      case DeviceType.mobile:
        return 20;
      case DeviceType.tablet:
        return 22;
      case DeviceType.desktop:
        return 24;
    }
  }

  /// Heading 2 (18px mobile, 20px tablet, 22px desktop)
  static double get fontH2 {
    switch (deviceType) {
      case DeviceType.mobile:
        return 18;
      case DeviceType.tablet:
        return 20;
      case DeviceType.desktop:
        return 22;
    }
  }

  /// Heading 3 (16px mobile, 18px tablet, 20px desktop)
  static double get fontH3 {
    switch (deviceType) {
      case DeviceType.mobile:
        return 16;
      case DeviceType.tablet:
        return 18;
      case DeviceType.desktop:
        return 20;
    }
  }

  /// Body Large (14px mobile, 15px tablet, 16px desktop)
  static double get fontBodyLarge {
    switch (deviceType) {
      case DeviceType.mobile:
        return 14;
      case DeviceType.tablet:
        return 15;
      case DeviceType.desktop:
        return 16;
    }
  }

  /// Body Medium (13px mobile, 14px tablet, 15px desktop)
  static double get fontBody {
    switch (deviceType) {
      case DeviceType.mobile:
        return 13;
      case DeviceType.tablet:
        return 14;
      case DeviceType.desktop:
        return 15;
    }
  }

  /// Body Small (12px mobile, 13px tablet, 14px desktop)
  static double get fontBodySmall {
    switch (deviceType) {
      case DeviceType.mobile:
        return 12;
      case DeviceType.tablet:
        return 13;
      case DeviceType.desktop:
        return 14;
    }
  }

  /// Caption (11px mobile, 12px tablet, 13px desktop)
  static double get fontCaption {
    switch (deviceType) {
      case DeviceType.mobile:
        return 11;
      case DeviceType.tablet:
        return 12;
      case DeviceType.desktop:
        return 13;
    }
  }

  // ================= ADAPTIVE ICON SIZES =================

  /// Small Icon (16px mobile, 18px tablet, 20px desktop)
  static double get iconSM {
    switch (deviceType) {
      case DeviceType.mobile:
        return 16;
      case DeviceType.tablet:
        return 18;
      case DeviceType.desktop:
        return 20;
    }
  }

  /// Medium Icon (20px mobile, 22px tablet, 24px desktop)
  static double get iconMD {
    switch (deviceType) {
      case DeviceType.mobile:
        return 20;
      case DeviceType.tablet:
        return 22;
      case DeviceType.desktop:
        return 24;
    }
  }

  /// Large Icon (24px mobile, 28px tablet, 32px desktop)
  static double get iconLG {
    switch (deviceType) {
      case DeviceType.mobile:
        return 24;
      case DeviceType.tablet:
        return 28;
      case DeviceType.desktop:
        return 32;
    }
  }

  // ================= ADAPTIVE BORDER RADIUS =================

  /// Small Radius (8px mobile, 10px tablet, 12px desktop)
  static double get radiusSM {
    switch (deviceType) {
      case DeviceType.mobile:
        return 8;
      case DeviceType.tablet:
        return 10;
      case DeviceType.desktop:
        return 12;
    }
  }

  /// Medium Radius (12px mobile, 14px tablet, 16px desktop)
  static double get radiusMD {
    switch (deviceType) {
      case DeviceType.mobile:
        return 12;
      case DeviceType.tablet:
        return 14;
      case DeviceType.desktop:
        return 16;
    }
  }

  /// Large Radius (16px mobile, 18px tablet, 20px desktop)
  static double get radiusLG {
    switch (deviceType) {
      case DeviceType.mobile:
        return 16;
      case DeviceType.tablet:
        return 18;
      case DeviceType.desktop:
        return 20;
    }
  }

  // ================= LAYOUT HELPERS =================

  /// Maximum content width for readability
  static double get maxContentWidth {
    switch (deviceType) {
      case DeviceType.mobile:
        return double.infinity;
      case DeviceType.tablet:
        return 768;
      case DeviceType.desktop:
        return 1200;
    }
  }

  /// Sidebar width
  static double get sidebarWidth {
    if (isMobile) return screenWidth * 0.75; // 75% on mobile for drawer
    if (isTablet) return 240; // Fixed 240px on tablet
    return screenWidth * 0.18; // 18% on desktop
  }

  /// Collapsed sidebar width
  static double get sidebarCollapsedWidth {
    if (isMobile) return 0; // Hidden on mobile
    if (isTablet) return 70;
    return screenWidth * 0.07;
  }

  /// Number of columns for grid layouts
  static int get gridColumns {
    switch (deviceType) {
      case DeviceType.mobile:
        return 1;
      case DeviceType.tablet:
        return 2;
      case DeviceType.desktop:
        return 3;
    }
  }

  /// Grid spacing
  static double get gridSpacing {
    switch (deviceType) {
      case DeviceType.mobile:
        return 12;
      case DeviceType.tablet:
        return 16;
      case DeviceType.desktop:
        return 20;
    }
  }

  // ================= RESPONSIVE VALUE HELPERS =================

  /// Get different values based on device type
  static T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }

  /// Build different widgets based on device type
  static Widget adaptiveLayout({
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }
}

