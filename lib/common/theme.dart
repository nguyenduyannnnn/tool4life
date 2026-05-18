import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'design_system/ds.dart' as ds;

export 'design_system/ds.dart' hide AppTheme;

// Legacy aliases — kept as thin forwards onto the new Design System tokens so
// existing legacy screens build unchanged. New code should import
// `common/design_system/ds.dart` directly.

@Deprecated('Use DSPalette / context.dsColors via design_system/ds.dart')
class AppColors {
  AppColors._();

  static const Color primary = ds.DSPalette.mint500;
  static const Color secondary = ds.DSPalette.mint700;
  static const Color primarySecond = ds.DSPalette.mint400;
  static const Color accent = ds.DSPalette.neutral900;
  static const Color white = ds.DSPalette.neutral0;
  static const Color black = ds.DSPalette.neutral900;
  static const Color grey = ds.DSPalette.neutral500;
  static const Color line = ds.DSPalette.neutral200;
  static const Color warning = ds.DSPalette.warning;
  static const Color hint = ds.DSPalette.neutral400;
  static const Color shadowColor = Color(0xFFC6C6C6);
  static const Color backgroundLight = ds.DSPalette.neutral50;
  static const Color backgroundNotification = Color(0xFFECF4FF);
}

@Deprecated('Use DSTypography.fontFamily from design_system/ds.dart')
class AppFonts {
  AppFonts._();

  static const String robotoSerif = 'Roboto Serif';
  static const String sfProDisplay = 'SF Pro Display';
  static const String ibmPlexSans = 'IBM Plex Sans';
}

@Deprecated('Use DSSpacing / DSRadius from design_system/ds.dart')
class AppSizes {
  AppSizes._();

  static const double ultraPadding = ds.DSSpacing.xxxl;
  static const double maxPadding = ds.DSSpacing.lg;
  static const double minPadding = ds.DSSpacing.sm;
  static const double onTap = 48;
  static const double icon = 20;
  static const double line = 0.5;
  static const double radius = ds.DSRadius.sm;
  static const double sizeDesktop = 1100;
  static const double sizeTablet = 650;
}

@Deprecated('Use DSTypography from design_system/ds.dart')
enum AppTextSizes {
  tiny(10.0),
  subBody(12.0),
  body(14.0),
  subTitle(16.0),
  title(18.0),
  header(26.0);

  const AppTextSizes(this.value);

  final double value;
}

@Deprecated('Use DSMotion from design_system/ds.dart')
class AppAnimation {
  AppAnimation._();

  static const Duration duration = ds.DSMotion.slow;
  static const Curve curve = Curves.fastOutSlowIn;
}

class AppFormat {
  AppFormat._();

  static final DateFormat date = DateFormat('dd/MM/yyyy');
  static final DateFormat dateResponse = DateFormat('dd-MM-yyyy');
  static final NumberFormat money = NumberFormat('#,###.###');
}

@Deprecated('Use AppTheme.light from design_system/ds.dart')
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => ds.AppTheme.light;
}
