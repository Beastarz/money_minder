import 'package:flutter_test/flutter_test.dart';
import 'package:money_minder/models/online/user.dart';

void main() {
  group('User model', () {
    test('fromMap creates a valid User object', () {
      final map = {
        'username': 'john_doe',
        'phoneNumber': '123456789',
      };

      final user = User.fromMap(map, 'uid123');

      expect(user.uid, 'uid123');
      expect(user.username, 'john_doe');
      expect(user.phoneNumber, '123456789');
    });

    test('toMap returns correct map', () {
      final user = User(uid: 'uid456', username: 'jane_doe', phoneNumber: '987654321');

      final result = user.toMap();

      expect(result['username'], 'jane_doe');
      expect(result['phoneNumber'], '987654321');
    });

    test('updatePhoneNumber changes the phone number', () {
      final user = User(uid: 'uid789', username: 'alex', phoneNumber: '000000000');

      user.updatePhoneNumber('111222333');

      expect(user.phoneNumber, '111222333');
    });
  });
}
