import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_minder/components/notification/notification_helper.dart';

void main() {
  group('NotificationHelper', () {
    test('convertTimeToString should format TimeOfDay correctly', () {
      expect(NotificationHelper.convertTimeToString(TimeOfDay(hour: 9, minute: 5)), '09:05');
      expect(NotificationHelper.convertTimeToString(TimeOfDay(hour: 23, minute: 59)), '23:59');
      expect(NotificationHelper.convertTimeToString(TimeOfDay(hour: 0, minute: 0)), '00:00');
    });

    test('convertStringToTime should parse string correctly to TimeOfDay', () {
      TimeOfDay time1 = NotificationHelper.convertStringToTime('09:05');
      expect(time1.hour, 9);
      expect(time1.minute, 5);

      TimeOfDay time2 = NotificationHelper.convertStringToTime('23:59');
      expect(time2.hour, 23);
      expect(time2.minute, 59);

      TimeOfDay time3 = NotificationHelper.convertStringToTime('00:00');
      expect(time3.hour, 0);
      expect(time3.minute, 0);
    });

    test('round-trip conversion: TimeOfDay -> String -> TimeOfDay', () {
      final originalTime = TimeOfDay(hour: 14, minute: 30);
      final timeString = NotificationHelper.convertTimeToString(originalTime);
      final parsedTime = NotificationHelper.convertStringToTime(timeString);

      expect(parsedTime.hour, originalTime.hour);
      expect(parsedTime.minute, originalTime.minute);
    });
  });
}
