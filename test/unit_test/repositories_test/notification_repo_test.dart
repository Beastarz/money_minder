import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:money_minder/models/notification_time.dart';
import 'package:money_minder/repositories/notification_time_repositories.dart';

import 'test.mocks.dart';

void main() {
  late NotificationTimeRepositories repo;
  late MockDatabaseService mockDbService;
  late MockDatabase mockDatabase;

  setUp(() {
    mockDbService = MockDatabaseService();
    mockDatabase = MockDatabase();

    when(mockDbService.database).thenAnswer((_) async => mockDatabase);

    NotificationTimeRepositories.instance.dbService = mockDbService;
    repo = NotificationTimeRepositories.instance;
  });

  group('NotificationTimeRepositories', () {
    test('getNotificationTime returns null if table is empty', () async {
      when(mockDatabase.query('notification_time')).thenAnswer((_) async => []);

      final result = await repo.getNotificationTime();

      expect(result, isNull);
      verify(mockDatabase.query('notification_time')).called(1);
    });

    test('getNotificationTime returns a NotificationTime object when data exists', () async {
      final mockData = {
        'time': '8:30',
      };

      when(mockDatabase.query('notification_time')).thenAnswer((_) async => [mockData]);

      final result = await repo.getNotificationTime();

      expect(result, isA<NotificationTime>());
      expect(result?.time.hour, 8);
      expect(result?.time.minute, 30);
      verify(mockDatabase.query('notification_time')).called(1);
    });

    test('addNotificationTime inserts a new notification time', () async {
      final map = {'time': '09:15'};

      when(mockDatabase.insert('notification_time', map)).thenAnswer((_) async => 1);

      await repo.addNotificationTime(map);

      verify(mockDatabase.insert('notification_time', map)).called(1);
    });

    test('updateNotificationTime updates existing notification time', () async {
      final map = {'time': '10:45'};

      when(mockDatabase.update('notification_time', map)).thenAnswer((_) async => 1);

      await repo.updateNotificationTime(map);

      verify(mockDatabase.update('notification_time', map)).called(1);
    });

    test('deleteNotificationTime deletes the notification time', () async {
      when(mockDatabase.delete('notification_time')).thenAnswer((_) async => 1);

      await repo.deleteNotificationTime();

      verify(mockDatabase.delete('notification_time')).called(1);
    });
  });
}
