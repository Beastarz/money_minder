import 'package:flutter/material.dart';

class NotificationHelper {

  /// convert time to a string to stored in database
  ///
  /// Parameter:
  ///
  /// - time: TimeOfDay object
  ///
  /// Returns: String
  static String convertTimeToString(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// convert string to time object
  ///
  /// Parameter:
  ///
  /// - timeString: String
  ///
  /// Returns: TimeOfDay
  static TimeOfDay convertStringToTime(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }
}