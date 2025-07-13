import 'package:firebase_auth/firebase_auth.dart';
import 'package:money_minder/firestore_repositories/budgets_repositories.dart';
import 'package:money_minder/firestore_repositories/currencies_repositories.dart';

import '../../firestore_repositories/fast_notes_repositories.dart';
import '../../firestore_repositories/transactions_repositories.dart';
import '../../models/account.dart';
import '../../models/budget.dart';
import '../../models/category.dart';
import '../../models/currency.dart';
import '../../models/fast_note.dart';
import '../../models/transaction.dart';
import '../../repositories/accounts_repositories.dart';
import '../../repositories/budget_repositories.dart';
import '../../repositories/category_repositories.dart';
import '../../repositories/currency_repositories.dart';
import '../../repositories/fast_note_repositories.dart';
import '../../repositories/transactions_repositories.dart';

class FirebaseDataHelper {

  static Map<int, String> idToAccount(List<Map<String, dynamic>> accounts) {
    final Map<int, String> accountMap = {};
    for (var account in accounts) {
      accountMap[account['id']] = account['name'];
    }
    return accountMap;
  }

  static Map<int, String> idToCategory(List<Map<String, dynamic>> categories){
    final Map<int, String> categoryMap = {};
    for (var category in categories) {
      categoryMap[category['id']] = category['name'];
    }
    return categoryMap;
  }

  static Map<String, int> accountToId(List<Map<String, dynamic>> accounts) {
    final Map<String, int> accountMap = {};
    for (var account in accounts) {
      accountMap[account['name']] = account['id'];
    }
    return accountMap;
  }

  static Map<String, int> categoryToId(List<Map<String, dynamic>> categories){
    final Map<String, int> categoryMap = {};
    for (var category in categories) {
      categoryMap[category['name']] = category['id'];
    }
    return categoryMap;
  }

  static Future<void> addAccounts(List<Map<String, dynamic>> accounts) async {
    AccountsRepositories.instance.deleteAllAccounts(); // delete the main accounts
    for (Map<String, dynamic> account in accounts) {
      await AccountsRepositories.instance.createAccount(Account.insertAsRawMap(
          name: account['name'],
          balance: account['balance'],
          icon: account['icon'],
          isMain: account['is_main'],
          color: account['color'],
          description: account['description'],
          isIncludesInTotal: account['includes_in_total'],
          type: account['type'],
          currency: account['currency']));
    }
  }

  static Future<void> addCategories(List<Map<String, dynamic>> categories) async {
    for (Map<String, dynamic> category in categories) {
      await CategoryRepositories.instance.createCategory(Category.insertAsMap(
          name: category['name'],
          position: category['position'],
          codePoint: category['icon'],
          colorValue: category['color'],
          isExpense: category['is_expense'] == 1 ? true : false
      ));
    }
  }

  static Future<void> addTransactions(Map<String, int> accountMap, Map<String, int> categoryMap, User user) async {
    final data = await FirebaseTransactionsRepositories.instance.getAllTransactions(user.uid);
    for (var element in data) {
      Map<String, dynamic> transaction = Map<String, dynamic>.from(element);
      transaction['from_account_id'] = accountMap[element['from_account']];
      if (element['type'] == 'transfer') {
        transaction['to_account_id'] = accountMap[element['to_account']];
      } else {
        transaction['to_category_id'] = categoryMap[element['to_category']];
      }
      await TransactionsRepositories.instance.createTransaction(Transaction.insertAsRawMap(
        amount: transaction['amount'],
        currency: transaction['currency'],
        date: transaction['date'],
        fromAccountId: transaction['from_account_id'],
        note: transaction['note'],
        toAccountId: transaction['to_account_id'],
        toCategoryId: transaction['to_category_id'],
        type: transaction['type'],
      ));
    }
  }

  static Future<void> addBudgets(Map<String, int> categoryMap, User user) async {
    final data = await FirebaseBudgetsRepositories.instance.getAllBudgets(user.uid);
    for (var element in data) {
      Map<String, dynamic> budget = Map<String, dynamic>.from(element);
      budget['category_id'] = categoryMap[element['category']];
      await BudgetRepositories.instance.createBudget(Budget.insertAsMap(
        amount: budget['amount'],
        month: budget['month'],
        year: budget['year'],
        categoryId: budget['category_id'],
      ));
    }
  }

  static Future<void> addFastNotes(User user) async {
    final data = await FirebaseFastNotesRepositories.instance.getAllFastNotes(user.uid);
    for (var element in data) {
      Map<String, dynamic> fastNote = Map<String, dynamic>.from(element);
      await FastNoteRepositories.instance.createFastNote(FastNote.insertAsMap(
        note: fastNote['note'],
        codePoint: fastNote['icon'],
        categoryId: fastNote['category_id'],
      ));
    }
  }

  static Future<void> setMainCurrency(User user) async {
    final data = await FirebaseCurrencyRepositories.instance.getMainCurrency(user.uid);
    await CurrencyRepositories.instance.setMainCurrency(Currency.of(data.first['main_currency'].toLowerCase()));
  }
}