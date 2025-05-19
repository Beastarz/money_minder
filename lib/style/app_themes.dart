import 'package:flutter/material.dart';
import 'app_color.dart';
import 'app_size.dart';

/// A central class to manage light and dark themes for the app.
class AppThemes {

  /// Light theme configuration using custom colors.
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColor.primary,
    primaryColor: AppColor.primary,
    iconTheme: IconThemeData(
        color: AppColor.darkIcon,
        size: AppSize.bigIcon,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: AppColor.darkText),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColor.secondary,
      iconTheme: IconThemeData(
          color: AppColor.darkIcon,
          size: AppSize.smallIcon
      ),
      titleTextStyle: TextStyle(
        color: AppColor.darkText,
        fontSize: AppSize.heading2,
      ),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: AppColor.quaternary,
      textTheme: ButtonTextTheme.primary,
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
