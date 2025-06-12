import '../db/database.dart';
import '../models/category.dart';

class CategoriesRepositories {

  DatabaseService dbService = DatabaseService.instance;

  CategoriesRepositories._privateConstructor();

  static final CategoriesRepositories instance = CategoriesRepositories._privateConstructor();

  Future<List<Category>> getAllCategories() async {
    final db = await dbService.database;
    List<Map<String, dynamic>> result = await db.query(
        'categories',
        orderBy: 'position ASC');
    return result.map((row) => Category.fromMap(row)).toList();
  }

  Future<List<Category>> getCategoriesByType(bool isExpense) async {
    final db = await dbService.database;
    List<Map<String, dynamic>> result = await db.query(
        'categories',
        where: 'is_expense = ?',
        whereArgs: [isExpense ? 1 : 0],
        orderBy: 'position ASC');
    return result.map((row) => Category.fromMap(row)).toList();
  }

  Future<void> updatePosition(int id, int newPosition) async {
    final db = await dbService.database;
    await db.update(
        'categories',
        {'position': newPosition},
        where: 'id = ?',
        whereArgs: [id]
    );
  }

  Future<void> close() async {
    final db = await dbService.database;
    await db.close();
  }
}