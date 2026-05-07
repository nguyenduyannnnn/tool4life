import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppColors {
  static const primary = Color(0xFF1890FF);
  static const secondary = Color(0xFF007bc2);
  static const primarySecond = Color(0xFF40A9FF);
  static const accent = Color(0xFF070922);
  static const white = Colors.white;
  static const black = Colors.black;
  static Color grey = Colors.grey[600]!;
  static Color line = Colors.grey[300]!;
  static const warning = Color(0xFFffc107);
  static Color hint = Colors.grey[400]!;
  static const shadowColor = Color(0xFFC6C6C6);
  static const backgroundLight = Color(0xFFF8F8F8);
  static const backgroundNotification = Color(0xFFECF4FF);
}

class AppFonts {
  static const robotoSerif = "Roboto Serif";
  static const sfProDisplay = "SF Pro Display";
  static const ibmPlexSans = "IBM Plex Sans";
}

class AppSizes {
  static const double ultraPadding = 32;
  static const double maxPadding = 16;
  static const double minPadding = 8;
  static const double onTap = 48;
  static const double icon = 20;
  static const double line = 0.5;
  static const double radius = 5.0;
  static const double sizeDesktop = 1100;
  static const double sizeTablet = 650;
}

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

class AppAnimation {
  static const Duration duration = Duration(milliseconds: 500);
  static const Curve curve = Curves.fastOutSlowIn;
}

class AppFormat {
  static DateFormat date = DateFormat("dd/MM/yyyy");
  static DateFormat dateResponse = DateFormat("dd-MM-yyyy");
  static NumberFormat money = NumberFormat("#,###.###");
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
        primaryColor: AppColors.primary,
        fontFamily: AppFonts.ibmPlexSans,
        useMaterial3: false,
        checkboxTheme: CheckboxThemeData(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          fillColor: WidgetStateProperty.resolveWith(
            (states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.primary;
              }
              return Colors.white;
            },
          ),
          checkColor: WidgetStateProperty.all((Colors.white)),
          side: BorderSide(color: AppColors.grey.withValues(alpha: 0.6)),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4.0)),
          ),
        ),
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        }));
  }
}
