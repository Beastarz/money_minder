import 'package:money_minder/db/database.dart';
import 'package:money_minder/models/account.dart';
import 'package:money_minder/models/category.dart';
import 'package:money_minder/repositories/accounts_repositories.dart';
import 'package:money_minder/repositories/categories_repositories.dart';
import 'package:sqflite/sqflite.dart' as sqf;

import '../models/budget.dart';

class BudgetRepositories {
  DatabaseService dbService = DatabaseService.instance;

  static final BudgetRepositories instance = BudgetRepositories._privateConstructor();
  BudgetRepositories._privateConstructor();

  Future<List<Budget>> getBudgets() async {
    sqf.Database db = await dbService.database;

    List<Account> accounts = await AccountsRepository.instance.getAllAccounts();
    List<Category> categories = await CategoriesRepositories.instance.getAllCategories();
    List<Map<String, dynamic>> res = await db.query('budgets');
    List<Budget> budgets = [];
    for (Map<String, dynamic> r in res) {
      Account? account = r['account_id'] == null
          ? null
          : accounts.firstWhere((account) => account.id == r['account_id']);
      Category? category = r['category_id'] == null
          ? null
          : categories.firstWhere((category) => category.id == r['category_id']);
      budgets.add(Budget.fromMap(r, category, account));
    }
    return budgets;
  }
}