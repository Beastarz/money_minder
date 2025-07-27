import 'package:flutter_test/flutter_test.dart';
import 'package:money_minder/models/passcode.dart';

void main() {
  group('Passcode model', () {
    test('fromMap creates Passcode correctly from map', () {
      final map = {
        'salt': 'randomSalt123',
        'encrypted_passcode': 'encrypted123',
        'active_period': 3600,
      };

      final passcode = Passcode.fromMap(map);

      expect(passcode.salt, 'randomSalt123');
      expect(passcode.encryptedPasscode, 'encrypted123');
      expect(passcode.activePeriod, 3600);
    });

    test('insertAsMap converts Passcode fields to map correctly', () {
      final salt = 'mySalt';
      final encryptedPasscode = 'abcXYZ';
      final activePeriod = 120;

      final map = Passcode.insertAsMap(salt, encryptedPasscode, activePeriod);

      expect(map['salt'], 'mySalt');
      expect(map['encrypted_passcode'], 'abcXYZ');
      expect(map['active_period'], 120);
    });
  });
}
