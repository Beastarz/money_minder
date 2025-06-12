import 'package:money_minder/components/transaction/transaction_helper.dart';
import 'package:money_minder/models/recurrence.dart';
import 'package:sqflite/sqflite.dart';

import '../db/database.dart';
import '../models/account.dart';
import '../models/category.dart';
import '../models/currency.dart';
import '../models/transaction.dart';
import 'accounts_repositories.dart';
import 'categories_repositories.dart';
import 'currency_repositories.dart';

class RecurrenceRepositories {
  DatabaseService dbService = DatabaseService.instance;

  RecurrenceRepositories._privateConstructor();

  static RecurrenceRepositories instance = RecurrenceRepositories._privateConstructor();

  Future<List<Recurrence>> getAndCheckRecurrences() async {
    Database db = await dbService.database;

    List<Account> accounts = await AccountsRepository.instance.getAllAccounts();
    List<Category> categories = await CategoriesRepositories.instance.getAllCategories();
    List<Map<String, dynamic>> res = await db.query('recurrence');
    Currency mainCurrency = await CurrencyRepositories.instance.getMainCurrency();
    List<Recurrence>  recurrences = [];

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
      Recurrence curr = Recurrence.fromMap(r, fromAccount, toAccount, toCategory, mainCurrency,);

      /// check recurrence
      if (curr.isOverdue) {
        while (curr.isOverdue) {
          switch(curr.type) {
            case TransactionType.expense:
              TransactionHelper.proceedExpense(curr.date, curr.fromAccount.id, curr.toCategory!, curr.amount, curr.currency, curr.note);
            case TransactionType.income:
              TransactionHelper.proceedIncome(curr.date, curr.fromAccount.id, curr.toCategory!, curr.amount, curr.currency, curr.note);
            case TransactionType.transfer:
              TransactionHelper.proceedTransfer(curr.date, curr.fromAccount.id, curr.toAccount!.id, curr.amount, curr.currency, curr.note);
          }
          if (curr.isNone) {
            break;
          }
          curr = curr.increment();
        }
        if (curr.isNone) {
          deleteRecurrence(curr.id);
          continue;
        }
        updateRecurrence(curr);
      }
      recurrences.add(curr);
    }
    return recurrences;
  }

  Future<void> createRecurrence(Map<String, dynamic> recurrence) async {
    Database db = await dbService.database;
    await db.insert('recurrence', recurrence);
  }

  Future<void> updateRecurrence(Recurrence recurrence) async {
    Database db = await dbService.database;
    await db.update('recurrence', recurrence.toMap(), where: 'id = ?', whereArgs: [recurrence.id]);
  }


  Future<void> deleteRecurrenceByAccountId(int id) async {
    Database db = await dbService.database;
    await db.delete('recurrence', where: 'from_account_id = ?', whereArgs: [id]);
    await db.delete('recurrence', where: 'to_account_id = ?', whereArgs: [id]);
  }

  Future<void> deleteRecurrence(int id) async {
    Database db = await dbService.database;
    await db.delete('recurrence', where: 'id = ?', whereArgs: [id]);
  }
}