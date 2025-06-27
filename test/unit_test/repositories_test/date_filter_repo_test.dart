import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:money_minder/models/date_filter.dart';
import 'package:money_minder/repositories/date_filter_repositories.dart';

import 'test.mocks.dart';

void main() {
  late MockDatabaseService mockDatabaseService;
  late MockDatabase mockDatabase;
  late DateFilterRepositories dateFilterRepositories;

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    mockDatabase = MockDatabase();

    DateFilterRepositories.setMockDbService(mockDatabaseService);

    dateFilterRepositories = DateFilterRepositories.instance;

    when(mockDatabaseService.database).thenAnswer((_) async => mockDatabase);
  });

  group('dateFilterRepositories', () {
    final dateFilterMap = {
      'type': 'month',
    };

    test('getFateFilter should return date filter', () async {
      when(mockDatabase.query('date_filter')).thenAnswer((_) async => [dateFilterMap]);

      final res = await dateFilterRepositories.getDateFilter();

      verify(mockDatabase.query('date_filter')).called(1);

      expect(res.type, DateFilterType.month);
      expect(res.duration, null);
    });

    test('update dateFilter should delete current filter and create a new date filter', () async {
      DateFilter updatedFilter = DateFilter.fromType(DateFilterType.year);

      when(mockDatabase.rawDelete('DELETE FROM date_filter')).thenAnswer((_) async => 1);
      when(mockDatabase.insert('date_filter', updatedFilter.toMap())).thenAnswer((_) async => 1);

      await dateFilterRepositories.updateDateFilter(updatedFilter);

      verify(mockDatabase.rawDelete('DELETE FROM date_filter')).called(1);
      verify(mockDatabase.insert('date_filter', updatedFilter.toMap())).called(1);
    });
  });
}