import 'package:flutter/material.dart';
import 'package:money_minder/db/database.dart';
import 'package:money_minder/models/account.dart';
import 'package:money_minder/models/category.dart';
import 'package:money_minder/models/currency.dart';
import 'package:money_minder/repositories/accounts_repositories.dart';
import 'package:money_minder/repositories/categories_repositories.dart';
import 'package:money_minder/repositories/currency_repositories.dart';
import 'package:sqflite/sqflite.dart' as sqf;
import 'package:money_minder/models/transaction.dart';

class TransactionsRepositories {
  DatabaseService _dbService = DatabaseService.instance;

  TransactionsRepositories._privateConstructor();

  static final TransactionsRepositories _instance = TransactionsRepositories._privateConstructor();

  static TransactionsRepositories? _testInstance;

  static TransactionsRepositories get instance => _testInstance ?? _instance;

  @visibleForTesting
  static void setMockDbService(DatabaseService mockService) {
    _instance._dbService = mockService;
  }

  @visibleForTesting
  static void setTestInstance(TransactionsRepositories testInstance) {
    _testInstance = testInstance;
  }

  @visibleForTesting
  static void resetInstance() {
    _instance._dbService = DatabaseService.instance;
    _testInstance = null;
  }

  Future<void> createTransaction(Map<String, dynamic> transaction) async {
    sqf.Database db = await _dbService.database;
    await db.insert('transactions', transaction);
  }

  Future<void> updateTransaction(Transaction transaction) async {
    sqf.Database db = await _dbService.database;
    await db.update('transactions', transaction.toMap(), where: 'id = ?', whereArgs: [transaction.id]);
  }

  Future<List<Transaction>> getTransactions() async {
    sqf.Database db = await _dbService.database;

    List<Account> accounts = await AccountsRepositories.instance.getAllAccounts();
    List<Category> categories = await CategoriesRepositories.instance.getAllCategories();
    List<Map<String, dynamic>> res = await db.query('transactions');
    Currency mainCurrency = await CurrencyRepositories.instance.getMainCurrency();
    List<Transaction> transactions = [];

    for (Map<String, dynamic> r in res) {
      if (r['to_account_id'] == null && r['to_category_id'] == null) {
        continue;
      }
      Account fromAccount= accounts.firstWhere((account) => account.id == r['from_account_id']);
      Account? toAccount = r['to_account_id'] == null
          ? null
          : accounts.firstWhere((account) => account.id == r['to_account_id']);
      Category? toCategory = r['to_category_id'] == null
          ? null
          : categories.firstWhere((category) => category.id == r['to_category_id']);
      transactions.add(Transaction.fromMap(r, fromAccount, toAccount, toCategory, mainCurrency));
    }
    return transactions;
  }

  Future<void> deleteTransactionByAccountId(int id) async {
    sqf.Database db = await _dbService.database;
    await db.delete('transactions', where: 'from_account_id = ?', whereArgs: [id]);
    await db.delete('transactions', where: 'to_account_id = ?', whereArgs: [id]);
  }

  Future<void> deleteTransaction(int id) async {
    sqf.Database db = await _dbService.database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteTransactionByCategoryId(int id) async {
    sqf.Database db = await _dbService.database;
    await db.delete('transactions', where: 'to_category_id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllTransactions() async {
    sqf.Database db = await _dbService.database;
    await db.delete('transactions');
  }
}