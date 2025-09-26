import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:money_minder/models/currency.dart';
import 'package:money_minder/repositories/currency_repositories.dart';

import 'test.mocks.dart';

void main() {
  late MockDatabaseService mockDatabaseService;
  late MockDatabase mockDatabase;
  late CurrencyRepositories currencyRepositories;

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    mockDatabase = MockDatabase();

    CurrencyRepositories.setMockDbService(mockDatabaseService);

    currencyRepositories = CurrencyRepositories.instance;

    when(mockDatabaseService.database).thenAnswer((_) async => mockDatabase);
  });

  tearDown(() {
    CurrencyRepositories.resetInstance();
  });

  group('currencyRepositories', () {
    final sgdMap = {
      'name': 'sgd',
    };

    test('getMainCurrency should return main currency', () async {
      when(mockDatabase.query('main_currency')).thenAnswer((_) async => [sgdMap]);

      final res = await currencyRepositories.getMainCurrency();

      verify(mockDatabase.query('main_currency',)).called(1);

      expect(res.name, 'SGD');
    });

    test('setMainCurrency should set a new main currency', () async {
      when(mockDatabase.update('main_currency', {'name': 'MYR'})).thenAnswer((_) async => 1);

      await currencyRepositories.setMainCurrency(Currency.of('MYR'));

      verify(mockDatabase.update('main_currency', {'name': 'MYR'})).called(1);
    });
  });
}