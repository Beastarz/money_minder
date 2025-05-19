import 'package:flutter/cupertino.dart';
import 'package:money_minder/models/currency.dart';
import 'package:sqflite/sqflite.dart';

import '../db/database.dart';
import '../models/account.dart';
import 'currency_repositories.dart';

class AccountsRepository {

  DatabaseService dbService = DatabaseService.instance;

  Future<void> createAccount(Map<String, dynamic> account) async {
    final db = await dbService.database;
    int count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM accounts')) ?? 0;
    account['position'] = count;
    await db.insert('accounts', account);
  }

  Future<List<Account>> getAllAccounts() async {
    final db = await dbService.database;
     List<Map<String, dynamic>> result = await db.query('accounts', orderBy: 'position ASC');
     return result.map((row) => Account.fromMap(row)).toList();
  }

  Future<void> updateAccount(Account account) async {
    final db = await dbService.database;
    Map<String, dynamic> accountMap = account.toMap();
    await db.update('accounts', accountMap, where: 'id = ?', whereArgs: [accountMap['id']]);
  }

  Future<void> updateAccountPosition(List<Account> accounts) async {
    final db = await dbService.database;
    Batch batch = db.batch();

    for (int i = 0; i < accounts.length; i++) {
      Account account = accounts[i].copyWith(position: i);
      Map<String, dynamic> accountMap = account.toMap();
      batch.update('accounts', accountMap, where: 'id = ?', whereArgs: [accountMap['id']]);
    }
    await batch.commit();
  }

  Future<void> deleteAccount(Account account) async {
    final db = await dbService.database;
    await db.delete('accounts', where: 'id = ?', whereArgs: [account.id]);
  }

  Future<double> getSelectedAccountBalance() async {
    final db = await dbService.database;
    final result = await db.query('accounts', where: 'includes_in_total = 1');
    final Currency mainCurrency = await CurrencyRepositories()
        .getMainCurrency();
    double total = 0;
    if (result.isNotEmpty) {
      for (var row in result) {
        Account account = Account.fromMap(row);
        total +=
            Currency.convert(account.currency, mainCurrency, account.balance);
      }
    }
    return total;
  }

  Future<void> close() async {
    final db = await dbService.database;
    await db.close();
  }
}