import '../db/database.dart';
import '../models/category.dart';

class CategoriesRepositories {

  DatabaseService dbService = DatabaseService.instance;

  Future<List<Category>> getAllCategories(bool isExpense) async {
    final db = await dbService.database;
    List<Map<String, dynamic>> result = await db.query(
        'categories',
        where: 'is_expense = ?',
        whereArgs: [isExpense ? 1 : 0],
        orderBy: 'position ASC');
    return result.map((row) => Category.fromMap(row)).toList();
  }

  Future<void> close() async {
    final db = await dbService.database;
    await db.close();
  }
}