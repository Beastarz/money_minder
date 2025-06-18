import 'package:money_minder/db/database.dart';
import 'package:money_minder/models/category.dart';
import 'package:money_minder/repositories/categories_repositories.dart';
import 'package:sqflite/sqflite.dart' as sqf;

import '../models/budget.dart';

class BudgetRepositories {
  DatabaseService dbService = DatabaseService.instance;

  static final BudgetRepositories instance = BudgetRepositories._privateConstructor();
  BudgetRepositories._privateConstructor();

  /// use this to get all budgets
  ///
  /// Parameters:
  ///
  /// Returns: List\<Budget\>
  Future<List<Budget>> getBudgets() async {
    sqf.Database db = await dbService.database;

    List<Category> categories = await CategoriesRepositories.instance.getAllCategories();
    List<Map<String, dynamic>> res = await db.query('budgets');
    List<Budget> budgets = [];
    for (Map<String, dynamic> r in res) {
      Category category = categories.firstWhere((category) => category.id == r['category_id']);
      budgets.add(Budget.fromMap(r, category));
    }
    return budgets;
  }

  /// use this to get budget of the category in the month
  ///
  /// Parameters:
  ///
  /// int month: month of the budget
  ///
  /// int year: year of the budget
  ///
  /// Returns: List\<Budget\>
  ///
  /// Returns: List\<Budget\>
  Future<double> getBudget(int month, int year, int categoryId) async {
    sqf.Database db = await dbService.database;
    List<Map<String, dynamic>> res = await db.query(
        'budgets', where: 'month = ? AND year = ? AND category_id = ?',
        whereArgs: [month, year, categoryId]);
    return res.isNotEmpty ? res.first['amount'] : 0;
  }

  /// use this to get budget id of the category in the month
  ///
  /// Parameters:
  ///
  /// int month: month of the budget
  ///
  /// int year: year of the budget
  ///
  /// int categoryId: category id of the budget
  ///
  /// Returns: int
  Future<int> getBudgetId(int month, int year, int categoryId) async {
    sqf.Database db = await dbService.database;
    List<Map<String, dynamic>> res = await db.query('budgets', where: 'month = ? AND year = ? AND category_id = ?', whereArgs: [month, year, categoryId]);
    return res.isNotEmpty ? res.first['id'] : 0;
  }

  /// use this to create budget
  ///
  /// Parameters:
  ///
  /// Map\<String, dynamic\> budget: budget to be created
  ///
  /// Returns: void
  Future<void> createBudget(Map<String, dynamic> budget) async {
    sqf.Database db = await dbService.database;
    await db.insert('budgets', budget);
  }

  /// use this to update budget
  ///
  /// Parameters:
  ///
  /// Map\<String, dynamic\> budget: budget to be updated
  ///
  /// int id: id of the budget
  ///
  /// Returns: void
  Future<void> updateBudget(Map<String, dynamic> budget, int id) async {
    sqf.Database db = await dbService.database;
    await db.update('budgets', budget, where: 'id = ?', whereArgs: [id]);
  }

  /// use this to delete budget
  ///
  /// Parameters:
  ///
  /// int month: month of the budget
  ///
  /// int year: year of the budget
  ///
  /// int categoryId: category id of the budget
  ///
  /// Returns: void
  Future<void> deleteBudget(int month, int year, int categoryId) async {
    sqf.Database db = await dbService.database;
    await db.delete('budgets', where: 'year = ? AND month = ? AND category_id = ?', whereArgs: [year, month, categoryId]);
  }
}