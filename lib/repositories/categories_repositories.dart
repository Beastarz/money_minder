import '../db/database.dart';
import '../models/category.dart';

class CategoriesRepositories {

  DatabaseService dbService = DatabaseService.instance;

  CategoriesRepositories._privateConstructor();

  static final CategoriesRepositories instance = CategoriesRepositories._privateConstructor();

  /// use this to get all categories
  ///
  /// Parameters:
  ///
  /// Returns: List\<Category\>
  Future<List<Category>> getAllCategories() async {
    final db = await dbService.database;
    List<Map<String, dynamic>> result = await db.query(
        'categories',
        orderBy: 'position ASC');
    return result.map((row) => Category.fromMap(row)).toList();
  }

  /// use this to get all expense / income categories
  ///
  /// Parameters:
  ///
  /// bool isExpense: true if expense, false if income
  ///
  /// Returns: List\<Category\>
  Future<List<Category>> getCategoriesByType(bool isExpense) async {
    final db = await dbService.database;
    List<Map<String, dynamic>> result = await db.query(
        'categories',
        where: 'is_expense = ?',
        whereArgs: [isExpense ? 1 : 0],
        orderBy: 'position ASC');
    return result.map((row) => Category.fromMap(row)).toList();
  }

  /// update the position of the category
  ///
  /// Parameters:
  ///
  /// int id: id of the category
  ///
  /// int newPosition: new position of the category
  ///
  /// Returns: void
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