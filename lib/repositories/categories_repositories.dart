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

  /// update the categories name, icon and color
  ///
  /// Parameters:
  ///
  /// Map\<String, dynamic\> category: new data for the category
  ///
  /// int id: id of the category
  Future<void> updateCategory(Map<String, dynamic> category, int id) async {
    final db = await dbService.database;
    await db.update(
        'categories',
        category,
        where: 'id = ?',
        whereArgs: [id]);
  }

  /// delete the category by Id
  ///
  /// Parameters:
  ///
  /// int id: id of the category
  ///
  /// Returns: void
  Future<void> deleteCategory(int id) async {
    final db = await dbService.database;
    await db.delete(
        'categories',
        where: 'id = ?',
        whereArgs: [id]);
  }

  /// create a new category
  ///
  /// Parameters:
  ///
  /// Map\<String, dynamic\> category: data for the new category
  ///
  /// Returns: void
  Future<void> createCategory(Map<String, dynamic> category) async {
    final db = await dbService.database;
    await db.insert(
        'categories',
        category);
  }
}