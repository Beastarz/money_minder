import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:money_minder/models/freeze_time.dart';
import 'package:money_minder/repositories/freeze_time_repositories.dart';

import 'test.mocks.dart';

void main() {
  late FreezeTimeRepositories repo;
  late MockDatabaseService mockDbService;
  late MockDatabase mockDatabase;

  setUp(() {
    mockDbService = MockDatabaseService();
    mockDatabase = MockDatabase();

    when(mockDbService.database).thenAnswer((_) async => mockDatabase);

    FreezeTimeRepositories.instance.dbService = mockDbService;
    repo = FreezeTimeRepositories.instance;
  });

  group('FreezeTimeRepositories', () {
    test('getFreezeTime returns empty list when no data exists', () async {
      when(mockDatabase.query('freeze_time')).thenAnswer((_) async => []);

      final result = await repo.getFreezeTime();

      expect(result, isEmpty);
      verify(mockDatabase.query('freeze_time')).called(1);
    });

    test('getFreezeTime returns a list of FreezeTime objects when data exists', () async {
      final now = DateTime.now();
      final mockData = {
        'frozen_count': 2,
        'frozen_until': now.millisecondsSinceEpoch,
      };

      when(mockDatabase.query('freeze_time')).thenAnswer((_) async => [mockData]);

      final result = await repo.getFreezeTime();

      expect(result.length, 1);
      expect(result[0], isA<FreezeTime>());
      expect(result[0].frozenCount, 2);
      expect(result[0].frozenUntil.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
      verify(mockDatabase.query('freeze_time')).called(1);
    });

    test('addFreezeTime inserts a new freeze time', () async {
      final map = {
        'frozen_count': 3,
        'frozen_until': DateTime.now().millisecondsSinceEpoch,
      };

      when(mockDatabase.insert('freeze_time', map)).thenAnswer((_) async => 1);

      await repo.addFreezeTime(map);

      verify(mockDatabase.insert('freeze_time', map)).called(1);
    });

    test('deleteFreezeTime deletes the freeze time', () async {
      when(mockDatabase.delete('freeze_time')).thenAnswer((_) async => 1);

      await repo.deleteFreezeTime();

      verify(mockDatabase.delete('freeze_time')).called(1);
    });
  });
}
