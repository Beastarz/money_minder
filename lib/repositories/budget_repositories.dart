import 'package:flutter/cupertino.dart';
import 'package:money_minder/db/database.dart';
import 'package:money_minder/models/category.dart';
import 'package:money_minder/repositories/category_repositories.dart';
import 'package:sqflite/sqflite.dart' as sqf;

import '../models/budget.dart';

class BudgetRepositories {
  DatabaseService _dbService = DatabaseService.instance;

  BudgetRepositories._privateConstructor();

  static final BudgetRepositories _instance = BudgetRepositories._privateConstructor();


  static BudgetRepositories get instance =>  _instance;

  @visibleForTesting
  static void setMockDbService(DatabaseService mockService) {
    _instance._dbService = mockService;
  }

  @visibleForTesting
  static void resetInstance() {
    _instance._dbService = DatabaseService.instance;
  }


  /// use this to get all budgets
  ///
  /// Parameters:
  ///
  /// Returns: List\<Budget\>
  Future<List<Budget>> getBudgets() async {
    sqf.Database db = await _dbService.database;

    List<Category> categories = await CategoryRepositories.instance.getAllCategories();
    List<Map<String, dynamic>> res = await db.query('budgets');
    List<Budget> budgets = [];
    for (Map<String, dynamic> r in res) {
      Category category = categories.firstWhere((category) => category.id == r['category_id']);
      budgets.add(Budget.fromMap(r, category));
    }
    return budgets;
  }

  /// get all budgets
  ///
  /// Returns: List\<Map\<String, dynamic\>\>
  Future<List<Map<String, dynamic>>> getRawBudgets() async {
    sqf.Database db = await _dbService.database;
    List<Map<String, dynamic>> res = await db.query('budgets');
    return res;
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
    sqf.Database db = await _dbService.database;
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
    sqf.Database db = await _dbService.database;
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
    sqf.Database db = await _dbService.database;
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
    sqf.Database db = await _dbService.database;
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
    sqf.Database db = await _dbService.database;
    await db.delete('budgets', where: 'year = ? AND month = ? AND category_id = ?', whereArgs: [year, month, categoryId]);
  }

  /// delete all budget with the same category id
  ///
  /// Parameters:
  ///
  /// int categoryId: category id of the budget
  ///
  /// Returns: void
  Future<void> deleteBudgetById(int categoryId) async {
    sqf.Database db = await _dbService.database;
    await db.delete('budgets', where: 'category_id = ?', whereArgs: [categoryId]);
  }

  /// delete all budget
  ///
  /// Returns: void
  Future<void> deleteAllBudgets() async {
    sqf.Database db = await _dbService.database;
    await db.delete('budgets');
  }
}