import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:money_minder/models/passcode.dart';
import 'package:money_minder/repositories/passcode_repositories.dart';

import 'test.mocks.dart';

void main() {
  late PasscodeRepositories repo;
  late MockDatabaseService mockDbService;
  late MockDatabase mockDatabase;

  setUp(() {
    mockDbService = MockDatabaseService();
    mockDatabase = MockDatabase();

    when(mockDbService.database).thenAnswer((_) async => mockDatabase);
    repo = PasscodeRepositories.instance;
    repo.dbService = mockDbService; // Inject mock
  });

  group('PasscodeRepositories', () {
    final mockPasscodeMap = {
      'salt': 'salt123',
      'encrypted_passcode': 'enc456',
      'active_period': 300,
    };

    test('getPasscode returns list of Passcode', () async {
      when(mockDatabase.query('passcode')).thenAnswer((_) async => [mockPasscodeMap]);

      final result = await repo.getPasscode();

      expect(result, isA<List<Passcode>>());
      expect(result.length, 1);
      expect(result[0].salt, 'salt123');
      expect(result[0].encryptedPasscode, 'enc456');
      expect(result[0].activePeriod, 300);
      verify(mockDatabase.query('passcode')).called(1);
    });

    test('addPasscode inserts passcode into database', () async {
      when(mockDatabase.insert('passcode', mockPasscodeMap)).thenAnswer((_) async => 1);

      await repo.addPasscode(mockPasscodeMap);

      verify(mockDatabase.insert('passcode', mockPasscodeMap)).called(1);
    });

    test('getActivePeriod returns the first active_period', () async {
      when(mockDatabase.query('passcode')).thenAnswer((_) async => [mockPasscodeMap]);

      final result = await repo.getActivePeriod();

      expect(result, 300);
      verify(mockDatabase.query('passcode')).called(1);
    });

    test('updateActivePeriod updates active_period value', () async {
      const newPeriod = 600;

      when(mockDatabase.update('passcode', {'active_period': newPeriod}))
          .thenAnswer((_) async => 1);

      await repo.updateActivePeriod(newPeriod);

      verify(mockDatabase.update('passcode', {'active_period': newPeriod})).called(1);
    });

    test('deletePasscode deletes all passcodes from table', () async {
      when(mockDatabase.delete('passcode')).thenAnswer((_) async => 1);

      await repo.deletePasscode();

      verify(mockDatabase.delete('passcode')).called(1);
    });
  });
}
