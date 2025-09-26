import 'package:flutter_test/flutter_test.dart';
import 'package:money_minder/components/lock_screen/passcode_helper.dart'; // Adjust this import if the file name is different
import 'dart:convert';
import 'package:crypto/crypto.dart';

void main() {
  group('PasscodeHelper', () {
    test('generateSalt returns base64 string of correct length', () {
      final salt = PasscodeHelper.generateSalt(16);
      final decoded = base64Decode(salt);
      expect(decoded.length, 16);
    });

    test('generateSha256Hash returns correct SHA256 hash', () {
      const input = 'password123';
      final expectedHash = sha256.convert(utf8.encode(input)).toString();
      expect(PasscodeHelper.generateSha256Hash(input), expectedHash);
    });

    test('verifyPasscode returns true for correct password', () {
      const password = 'mysecret';
      final encrypted = PasscodeHelper.generateSha256Hash(password);
      expect(PasscodeHelper.verifyPasscode(password, encrypted), isTrue);
    });

    test('verifyPasscode returns false for incorrect password', () {
      const password = 'mysecret';
      final encrypted = PasscodeHelper.generateSha256Hash(password);
      expect(PasscodeHelper.verifyPasscode('wrongpassword', encrypted), isFalse);
    });

    test('formattedDuration returns correct format for full time', () {
      final duration = Duration(hours: 2, minutes: 5, seconds: 9);
      final formatted = PasscodeHelper.formattedDuration(duration);
      expect(formatted, '02:05:09');
    });

    test('formattedDuration returns correct format with 0 padding', () {
      final duration = Duration(hours: 0, minutes: 3, seconds: 4);
      final formatted = PasscodeHelper.formattedDuration(duration);
      expect(formatted, '00:03:04');
    });
  });
}
