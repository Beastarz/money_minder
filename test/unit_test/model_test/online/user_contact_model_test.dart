import 'package:flutter_test/flutter_test.dart';
import 'package:money_minder/models/online/user_contact.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('UserContact', () {
    late Map<String, dynamic> userMap;

    setUp(() {
      userMap = {
        'username': 'Alice',
        'phoneNumber': '12345678',
        'nickname': 'Ali',
        'isBlocked': false,
      };
    });

    test('fromMap constructs correct instance', () {
      final contact = UserContact.fromMap('uid123', userMap);

      expect(contact.uid, 'uid123');
      expect(contact.username, 'Alice');
      expect(contact.phoneNumber, '12345678');
      expect(contact.nickname, 'Ali');
      expect(contact.isBlocked, false);
    });

    test('toMap returns expected map', () {
      final contact = UserContact.fromMap('uid123', userMap);
      final map = contact.toMap();

      expect(map, {
        'username': 'Alice',
        'phoneNumber': '12345678',
        'nickname': 'Ali',
        'isBlocked': false,
      });
    });

    test('insertAsMap creates map with correct default values', () {
      final map = UserContact.insertAsMap(
        username: 'Bob',
        nickname: 'Bobby',
        phoneNumber: '87654321',
      );

      expect(map['username'], 'Bob');
      expect(map['nickname'], 'Bobby');
      expect(map['phoneNumber'], '87654321');
      expect(map['isBlocked'], false);
      expect(map['createdAt'], isA<FieldValue>());
    });

    test('copyWith returns updated instance', () {
      final original = UserContact.fromMap('uid456', userMap);
      final updated = original.copyWith(
        nickname: 'Alicia',
        phoneNumber: '11111111',
      );

      expect(updated.uid, original.uid);
      expect(updated.username, original.username); // unchanged
      expect(updated.nickname, 'Alicia'); // updated
      expect(updated.phoneNumber, '11111111'); // updated
      expect(updated.isBlocked, original.isBlocked); // unchanged
    });

    test('toUserModel returns correct User instance', () {
      final contact = UserContact.fromMap('uid789', userMap);
      final user = contact.toUserModel();

      expect(user.uid, contact.uid);
      expect(user.username, contact.username);
      expect(user.phoneNumber, contact.phoneNumber);
    });
  });
}
