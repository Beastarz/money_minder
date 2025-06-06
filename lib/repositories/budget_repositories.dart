import 'package:money_minder/db/database.dart';
import 'package:money_minder/models/category.dart';
import 'package:money_minder/repositories/categories_repositories.dart';
import 'package:sqflite/sqflite.dart' as sqf;

import '../models/budget.dart';

class BudgetRepositories {
  DatabaseService dbService = DatabaseService.instance;

  static final BudgetRepositories instance = BudgetRepositories._privateConstructor();
  BudgetRepositories._privateConstructor();

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

  Future<double> getBudget(int month, int year, int categoryId) async {
    sqf.Database db = await dbService.database;
    List<Map<String, dynamic>> res = await db.query(
        'budgets', where: 'month = ? AND year = ? AND category_id = ?',
        whereArgs: [month, year, categoryId]);
    return res.isNotEmpty ? res.first['amount'] : 0;
  }

  Future<int> getBudgetId(int month, int year, int categoryId) async {
    sqf.Database db = await dbService.database;
    List<Map<String, dynamic>> res = await db.query('budgets', where: 'month = ? AND year = ? AND category_id = ?', whereArgs: [month, year, categoryId]);
    return res.isNotEmpty ? res.first['id'] : 0;
  }

  Future<void> createBudget(Map<String, dynamic> budget) async {
    sqf.Database db = await dbService.database;
    await db.insert('budgets', budget);
  }

  Future<void> updateBudget(Map<String, dynamic> budget, int id) async {
    sqf.Database db = await dbService.database;
    await db.update('budgets', budget, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteBudget(int month, int year, int categoryId) async {
    sqf.Database db = await dbService.database;
    await db.delete('budgets', where: 'year = ? AND month = ? AND category_id = ?', whereArgs: [year, month, categoryId]);
  }
}