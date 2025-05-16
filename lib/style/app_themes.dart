import 'package:flutter/material.dart';
import 'app_color.dart';

/// A central class to manage light and dark themes for the app.
class AppThemes {
  /// Light theme configuration using custom colors.
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColor.secondary,
    primaryColor: AppColor.primary,
    iconTheme: IconThemeData(color: AppColor.darkIcon),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: AppColor.darkText),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColor.tertiary,
      iconTheme: IconThemeData(color: AppColor.darkIcon),
      titleTextStyle: TextStyle(
        color: AppColor.darkText,
        fontSize: 20,
      ),
    ),
  );

  /// Dark theme configuration using custom colors.
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColor.primary,
    primaryColor: AppColor.secondary,
    iconTheme: IconThemeData(color: AppColor.lightIcon),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: AppColor.lightText),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColor.secondary,
      iconTheme: IconThemeData(color: AppColor.lightIcon),
      titleTextStyle: TextStyle(
        color:
        AppColor.lightText,
        fontSize: 20,
      ),
    ),
  );
}
