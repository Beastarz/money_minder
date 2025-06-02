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
  DatabaseService dbService = DatabaseService.instance;

  static final TransactionsRepositories instance = TransactionsRepositories._privateConstructor();
  TransactionsRepositories._privateConstructor();

  Future<void> createTransaction(Map<String, dynamic> transaction) async {
    sqf.Database db = await dbService.database;
    await db.insert('transactions', transaction);
  }

  Future<void> updateTransaction(Transaction transaction) async {
    sqf.Database db = await dbService.database;
    await db.update('transactions', transaction.toMap(), where: 'id = ?', whereArgs: [transaction.id]);
  }

  Future<List<Transaction>> getTransactions() async {
    sqf.Database db = await dbService.database;

    List<Account> accounts = await AccountsRepository.instance.getAllAccounts();
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

  Future<void> deleteTransaction(int id) async {
    sqf.Database db = await dbService.database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }
}