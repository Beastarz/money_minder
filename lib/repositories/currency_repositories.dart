import 'package:money_minder/db/database.dart';
import 'package:money_minder/models/currency.dart';
import 'package:sqflite/sqflite.dart';

class CurrencyRepositories {
  CurrencyRepositories._privateConstructor();

  static final CurrencyRepositories instance = CurrencyRepositories._privateConstructor();

  DatabaseService dbService = DatabaseService.instance;

  Future<List<Currency>> getCurrencies() async {
    Database db = await dbService.database;
    final result = await db.query('currencies');
    return result.map((e) => Currency.of(e['name'] as String)).toList();
  }

  Future<Currency> getMainCurrency() async {
    Database db = await dbService.database;
    final result = await db.query('currencies', where: 'is_main = 1');
    return Currency.of(result.first['name'] as String);
  }

  Future<void> close() async {
    final db = await dbService.database;
    await db.close();
  }
}