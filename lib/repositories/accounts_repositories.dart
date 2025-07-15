import 'package:flutter/cupertino.dart';
import 'package:money_minder/repositories/recurrence_repositories.dart';
import 'package:money_minder/repositories/transactions_repositories.dart';
import 'package:sqflite/sqflite.dart';

import '../db/database.dart';
import '../models/account.dart';

class AccountsRepositories {
  DatabaseService _dbService = DatabaseService.instance;

  AccountsRepositories._privateConstructor();

  static final AccountsRepositories _instance = AccountsRepositories._privateConstructor();

  static AccountsRepositories? _testInstance;

  static AccountsRepositories get instance => _testInstance ?? _instance;

  @visibleForTesting
  static void setMockDbService(DatabaseService mockService) {
    _instance._dbService = mockService;
  }

  @visibleForTesting
  static void setTestInstance(AccountsRepositories testInstance) {
    _testInstance = testInstance;
  }

  @visibleForTesting
  static void resetInstance() {
    _instance._dbService = DatabaseService.instance;
    _testInstance = null;
  }

  Future<void> createAccount(Map<String, dynamic> account) async {
    final db = await _dbService.database;
    int count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM accounts')) ?? 0;
    account['position'] = count;
    await db.insert('accounts', account);
  }

  Future<List<Account>> getAllAccounts() async {
    final db = await _dbService.database;
     List<Map<String, dynamic>> result = await db.query('accounts', orderBy: 'position ASC');
     return result.map((row) => Account.fromMap(row)).toList();
  }

  Future<List<Map<String, dynamic>>> getRawAccounts() async {
    final db = await _dbService.database;
    List<Map<String, dynamic>> result = await db.query('accounts');
    return result;
  }

  Future<Account> getAccountById(int id) async {
    final db = await _dbService.database;
    List<Map<String, dynamic>> result = await db.query('accounts', where: 'id = ?', whereArgs: [id]);
    return Account.fromMap(result.first);
  }

  Future<Account> getMainAccounts() async {
    final db = await _dbService.database;
    List<Map<String, dynamic>> result = await db.query('accounts',where: 'is_main = 1', orderBy: 'position ASC');
    return Account.fromMap(result.first);
  }

  Future<void> updateAccount(Account account) async {
    final db = await _dbService.database;
    Map<String, dynamic> accountMap = account.toMap();
    await db.update('accounts', accountMap, where: 'id = ?', whereArgs: [accountMap['id']]);
  }

  Future<void> updateIncludedAccount(List<int> selectedAccount) async {
    final db = await _dbService.database;
    final batch = db.batch();
    List<Account> res = await instance.getAllAccounts();
    for (Account account in res) {
      if (selectedAccount.contains(account.id)) {
        account = account.copyWith(isIncludesInTotal: true);
      } else {
        account = account.copyWith(isIncludesInTotal: false);
      }
      batch.update('accounts', account.toMap(), where: 'id = ?',
          whereArgs: [account.id]);
    }
    await batch.commit();
  }

  Future<void> updateAccountPosition(List<Account> accounts) async {
    final db = await _dbService.database;
    Batch batch = db.batch();

    for (int i = 0; i < accounts.length; i++) {
      Account account = accounts[i].copyWith(position: i);
      Map<String, dynamic> accountMap = account.toMap();
      batch.update('accounts', accountMap, where: 'id = ?', whereArgs: [accountMap['id']]);
    }
    await batch.commit();
  }

  Future<void> updateMainAccount(Account account) async {
    final db = await _dbService.database;
    Map<String, dynamic> mainAccount = await db.query('accounts', where: 'is_main = 1').then((value) => value.first);
    Account prevMainAccount = Account.fromMap(mainAccount).copyWith(isMain: false);
    await db.update('accounts', prevMainAccount.toMap(), where: 'id = ?', whereArgs: [prevMainAccount.id]);
    account = account.copyWith(isMain: true);
    await db.update('accounts', account.toMap(), where: 'id = ?', whereArgs: [account.id]);
  }

  Future<void> deleteAccount(int id) async {
    await TransactionsRepositories.instance.deleteTransactionByAccountId(id);
    await RecurrenceRepositories.instance.deleteRecurrenceByAccountId(id);

    final db = await _dbService.database;
    await db.delete('accounts', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllNonMainAccounts() async {
    final db = await _dbService.database;
    await db.delete('accounts', where: 'is_main = 0');
  }

  Future<void> deleteAllAccounts() async {
    final db = await _dbService.database;
    await db.delete('accounts');
  }

  Future<void> resetMainAccount() async {
    // ('Main Wallet', 0xe850, 0, 0xFF4CAF50, 1, 'My primary cash wallet', 1, 'accounts', 'sgd', 0)
    final db = await _dbService.database;
    await db.update('accounts', {
      'name': 'Main Wallet',
      'icon': 0xe850,
      'balance': 0,
      'color': 0xFF4CAF50,
      'is_main': 1,
      'description': 'My primary cash wallet',
      'includes_in_total': 1,
      'type': 'accounts',
      'currency': 'sgd',
      'position': 0,
    }, where: 'is_main = 1');
  }

  Future<void> close() async {
    final db = await _dbService.database;
    await db.close();
  }
}