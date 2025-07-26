import 'package:flutter_test/flutter_test.dart';
import 'package:money_minder/models/freeze_time.dart';

void main() {
  group('FreezeTime model', () {
    test('fromMap parses values correctly', () {
      final timestamp = DateTime(2025, 7, 25, 10, 30).millisecondsSinceEpoch;
      final map = {
        'frozen_count': 3,
        'frozen_until': timestamp,
      };

      final freezeTime = FreezeTime.fromMap(map);

      expect(freezeTime.frozenCount, 3);
      expect(freezeTime.frozenUntil.millisecondsSinceEpoch, timestamp);
      expect(freezeTime.frozenUntil.year, 2025);
      expect(freezeTime.frozenUntil.month, 7);
      expect(freezeTime.frozenUntil.day, 25);
      expect(freezeTime.frozenUntil.hour, 10);
      expect(freezeTime.frozenUntil.minute, 30);
    });

    test('insertAsMap serializes FreezeTime correctly', () {
      final freezeCount = 5;
      final frozenUntil = DateTime(2025, 12, 31, 23, 59);

      final map = FreezeTime.insertAsMap(freezeCount, frozenUntil);

      expect(map['frozen_count'], 5);
      expect(map['frozen_until'], frozenUntil.millisecondsSinceEpoch);
    });
  });
}
