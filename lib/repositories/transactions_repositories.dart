import 'package:money_minder/db/database.dart';
import 'package:sqflite/sqflite.dart' as sqf;
import 'package:money_minder/models/transaction.dart';

class TransactionsRepositories {
  DatabaseService dbService = DatabaseService.instance;

  Future<List<Transaction>> getTransactions() async {
    sqf.Database db = await dbService.database;
    List<Map<String, dynamic>> res = await db.query('transactions');
    return res.map((e) => Transaction.fromMap(e)).toList();
  }
}