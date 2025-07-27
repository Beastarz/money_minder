import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_minder/models/notification_time.dart';

void main() {
  group('NotificationTime model', () {
    test('fromMap parses time correctly', () {
      final map = {'time': '07:45'};
      final nt = NotificationTime.fromMap(map);

      expect(nt.time.hour, 7);
      expect(nt.time.minute, 45);
    });

    test('fromMap handles single-digit minutes', () {
      final map = {'time': '08:5'};
      final nt = NotificationTime.fromMap(map);

      expect(nt.time.hour, 8);
      expect(nt.time.minute, 5);
    });

    test('insertAsMap serializes TimeOfDay correctly with padded minutes', () {
      final time = TimeOfDay(hour: 9, minute: 3);
      final map = NotificationTime.insertAsMap(time);

      expect(map['time'], '09:03');
    });

    test('insertAsMap serializes TimeOfDay correctly with double digits', () {
      final time = TimeOfDay(hour: 18, minute: 45);
      final map = NotificationTime.insertAsMap(time);

      expect(map['time'], '18:45');
    });
  });
}
