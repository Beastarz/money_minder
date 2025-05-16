import 'package:flutter/material.dart';

import '../../style/app_color.dart';

class CalendarSelectorHelper {
  static Future<void> selectDate(BuildContext context) async {
    Navigator.pop(context);
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Select day',
      cancelText: 'Cancel',
      confirmText: 'Confirm',
      errorFormatText: 'Invalid date format',
      errorInvalidText: 'Invalid date',
      fieldLabelText: 'Date',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColor.tertiary,
              onPrimary: AppColor.primary,
              surface: AppColor.primary, // Modal background
              onSurface: AppColor.lightText, // Text color,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColor.lightText,
              ),
            ),
            textTheme: TextTheme(
              // Change this for input text style
              titleMedium: TextStyle(color: AppColor.lightText),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      // Use pickedDate
    }
  }

  static Future<void> showCustomDateRangePicker(BuildContext context) async {

    Navigator.pop(context);

    final DateTime now = DateTime.now();

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Select range',
      cancelText: 'Cancel',
      confirmText: 'Confirm',
      errorFormatText: 'Invalid date format',
      errorInvalidText: 'Invalid date',
      // barrierColor: AppColor.primary,
      initialDateRange: DateTimeRange(start: now, end: now),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColor.tertiary,
              onPrimary: AppColor.primary,
              surface: AppColor.primary,
              onSurface: AppColor.lightText,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                  foregroundColor: AppColor.lightText
              ),
            ),
            textTheme: TextTheme(
              // Change this for input text style
              titleMedium: TextStyle(color: AppColor.lightText),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      debugPrint('Range: ${picked.start} to ${picked.end}');
      // Update your state here
    }
  }

}

