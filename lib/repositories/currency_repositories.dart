import 'package:money_minder/db/database.dart';
import 'package:money_minder/models/currency.dart';
import 'package:sqflite/sqflite.dart';

class CurrencyRepositories {
  DatabaseService dbService = DatabaseService.instance;

  Future<Currency> getMainCurrency() async {
    Database db = await dbService.database;
    final result = await db.query('currencies', where: 'is_main = 1');
    return Currency.of(result.first['name'] as String);
  }
}