import 'package:flutter/material.dart';

import '../../models/date_filter.dart';
import '../../style/app_color.dart';

class CalendarSelectorHelper {

  static IconData getIcon(DateFilterType type) {
    switch (type) {
      case DateFilterType.all:
        return Icons.all_inclusive;
      case DateFilterType.year:
        return Icons.calendar_today;
      case DateFilterType.month:
        return Icons.calendar_month;
      case DateFilterType.week:
        return Icons.calendar_view_week;
      case DateFilterType.day:
        return Icons.date_range;
      case DateFilterType.range:
        return Icons.edit_calendar;
    }
  }

  static Future<void> selectDate(BuildContext context, Function(DateTime) callback) async {
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
            colorScheme: ColorScheme.light(
              primary: AppColor.tertiary,
              onPrimary: AppColor.quaternary,
              surface: AppColor.primary, // Modal background
              onSurface: AppColor.darkText, // Text color,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColor.darkText,
              ),
            ),
            // textTheme: TextTheme(
            //   // Change this for input text style
            //   bodyMedium: TextStyle(color: AppColor.darkText),
            //   titleMedium: TextStyle(color: AppColor.darkText),
            // ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      // Use pickedDate
      callback(pickedDate);
    }
  }

  static Future<void> showCustomDateRangePicker(BuildContext context, Function(DateTime, Duration) callback) async {

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
      initialDateRange: DateTimeRange(start: now, end: now),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColor.tertiary,
              onPrimary: AppColor.quaternary,
              secondary: AppColor.secondary,
              surface: AppColor.primary,
              onSurface: AppColor.darkText,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                  foregroundColor: AppColor.darkText
              ),
            ),
          //   textTheme: const TextTheme().copyWith(
          //     bodySmall: TextStyle(color: AppColor.darkText), // For the days of the month
          //     titleMedium: TextStyle(color: AppColor.darkText),
          // ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      callback(picked.start, Duration(days: picked.duration.inDays + 1));
    }
  }

}

