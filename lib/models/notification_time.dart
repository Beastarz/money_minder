import 'package:flutter/material.dart';
import 'package:money_minder/components/notification/notification_helper.dart';

class NotificationTime {
  final TimeOfDay time;

  const NotificationTime({
    required this.time,
  });

  /// Convert a Map object to a [NotificationTime] instance.
  ///
  /// The keys of the [map] must be:
  ///
  /// - 'time': The time of the notification.
  ///
  /// Returns a [NotificationTime] instance.
  static NotificationTime fromMap(Map<String, dynamic> map) {
    return NotificationTime(
      time: NotificationHelper.convertStringToTime(map['time']),
    );
  }

  /// Convert a [NotificationTime] instance to a Map object.
  ///
  /// Returns a Map object with the following keys:
  ///
  /// - 'time': The time of the notification.
  ///
  /// Returns a Map object.
  static Map<String, dynamic> insertAsMap(
      TimeOfDay time,
      ) {
    return {
      'time': NotificationHelper.convertTimeToString(time),
    };
  }
}