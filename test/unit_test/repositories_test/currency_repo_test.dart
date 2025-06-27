import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
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

  group('currencyRepositories', () {
    final sgdMap = {
      'name': 'sgd',
      'is_main': 1,
    };
    final myrMap = {
      'name': 'myr',
      'is_main': 0,
    };

    test('getCurrencies return all list of currencies', () async {
      when(mockDatabase.query('currencies')).thenAnswer((_) async => [sgdMap, myrMap]);

      final res = await currencyRepositories.getCurrencies();

      verify(mockDatabase.query('currencies')).called(1);

      expect(res[0].currency().name, 'sgd');
    });

    test('getMainCurrency should return main currency', () async {
      when(mockDatabase.query('currencies', where: 'is_main = 1')).thenAnswer((_) async => [sgdMap]);

      final res = await currencyRepositories.getMainCurrency();

      verify(mockDatabase.query('currencies', where: 'is_main = 1')).called(1);

      expect(res.currency().name, 'sgd');
    });
  });
}