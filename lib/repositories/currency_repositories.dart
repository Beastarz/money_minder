import 'package:flutter/cupertino.dart';
import 'package:money_minder/db/database.dart';
import 'package:money_minder/models/currency.dart';
import 'package:sqflite/sqflite.dart';

class CurrencyRepositories {
  DatabaseService _dbService = DatabaseService.instance;

  CurrencyRepositories._privateConstructor();

  static final CurrencyRepositories _instance = CurrencyRepositories._privateConstructor();

  static CurrencyRepositories? _testInstance;

  static CurrencyRepositories get instance => _testInstance ?? _instance;

  @visibleForTesting
  static void setMockDbService(DatabaseService mockService) {
    _instance._dbService = mockService;
  }

  @visibleForTesting
  static void setTestInstance(CurrencyRepositories testInstance) {
    _testInstance = testInstance;
  }

  @visibleForTesting
  static void resetInstance() {
    _instance._dbService = DatabaseService.instance;
    _testInstance = null;
  }

  Future<List<Currency>> getCurrencies() async {
    Database db = await _dbService.database;
    final result = await db.query('currencies');
    return result.map((e) => Currency.of(e['name'] as String)).toList();
  }

  Future<Currency> getMainCurrency() async {
    Database db = await _dbService.database;
    final result = await db.query('currencies', where: 'is_main = 1');
    return Currency.of(result.first['name'] as String);
  }

  Future<void> setMainCurrency(Currency currency) async {
    Database db = await _dbService.database;
    try {
      await db.update('currencies', {'is_main': 0});
      await db.update(
          'currencies', {'is_main': 1}, where: 'name = ?', whereArgs: [currency
          .currency()
          .name
      ]);
    } catch (e) {
      return;
    }
  }

  Future<void> close() async {
    final db = await _dbService.database;
    await db.close();
  }
}