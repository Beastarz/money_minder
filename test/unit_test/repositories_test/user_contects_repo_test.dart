import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:money_minder/models/user_contact.dart';
import 'package:money_minder/repositories/user_contacts_repositories.dart';

import 'test.mocks.dart';

void main() {
  late UserContactsRepositories userContactsRepositories;
  late MockDatabaseService mockDbService;
  late MockDatabase mockDatabase;

  setUp(() {
    mockDbService = MockDatabaseService();
    mockDatabase = MockDatabase();

    when(mockDbService.database).thenAnswer((_) async => mockDatabase);

    UserContactsRepositories.setMockDbService(mockDbService);
    userContactsRepositories = UserContactsRepositories.instance;
  });

  tearDown(() {
    UserContactsRepositories.resetInstance();
  });

  group('UserContactsRepositories', () {
    final mockData = [
      {'id': 1, 'nickname': 'name1', 'username': 'username1'},
      {'id': 2, 'nickname': 'name2', 'username': 'username2'},
    ];

    test('getUserContact returns a list of UserContact', () async {


      when(mockDatabase.query('user_contacts')).thenAnswer((_) async => mockData);

      final result = await userContactsRepositories.getUserContact();

      expect(result.length, 2);
      expect(result[0].nickname, 'name1');
      expect(result[1].username, 'username2');
    });

    test('addUserContact inserts a new user contact', () async {
      final newContactMap = {'username': 'username3', 'nickname': 'tom'};

      when(mockDatabase.insert('user_contacts', newContactMap))
          .thenAnswer((_) async => 1); // Simulate successful insertion

      await userContactsRepositories.addUserContact(newContactMap);

      verify(mockDatabase.insert('user_contacts', newContactMap)).called(1);
    });

    test('updateUserContact updates an existing user contact', () async {
      final updatedContact = UserContact.fromMap({'id': 1, 'username': 'username3', 'nickname': 'name3'});

      when(mockDatabase.update(
        'user_contacts',
        updatedContact.toMap(),
        where: 'id = ?',
        whereArgs: [updatedContact.id],
      )).thenAnswer((_) async => 1); // Simulate successful update

      await userContactsRepositories.updateUserContact(updatedContact);

      verify(mockDatabase.update(
        'user_contacts',
        updatedContact.toMap(),
        where: 'id = ?',
        whereArgs: [updatedContact.id],
      )).called(1);
    });

    test('deleteUserContact deletes a user contact by id', () async {
      const contactIdToDelete = 1;

      when(mockDatabase.delete(
        'user_contacts',
        where: 'id = ?',
        whereArgs: [contactIdToDelete],
      )).thenAnswer((_) async => 1); // Simulate successful deletion

      await userContactsRepositories.deleteUserContact(contactIdToDelete);

      verify(mockDatabase.delete(
        'user_contacts',
        where: 'id = ?',
        whereArgs: [contactIdToDelete],
      )).called(1);
    });

    test('deleteUserContact deletes a user contact by username', () async {
      const username = 'abc';

      when(mockDatabase.delete(
        'user_contacts',
        where: 'username = ?',
        whereArgs: [username],
      )).thenAnswer((_) async => 1); // Simulate successful deletion

      await userContactsRepositories.deleteUserContactByUsername(username);

      verify(mockDatabase.delete(
        'user_contacts',
        where: 'username = ?',
        whereArgs: [username],
      )).called(1);
    });
  });
}