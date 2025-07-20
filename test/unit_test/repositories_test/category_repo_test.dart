import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:money_minder/models/category.dart';
import 'package:money_minder/repositories/category_repositories.dart';

import 'test.mocks.dart';


void main() {
  late CategoryRepositories categoriesRepositories;
  late MockDatabaseService mockDbService;
  late MockDatabase mockDatabase;

  setUp(() {
    mockDbService = MockDatabaseService();
    mockDatabase = MockDatabase();
    when(mockDbService.database).thenAnswer((_) async => mockDatabase);

    CategoryRepositories.setMockDbService(mockDbService);
    categoriesRepositories = CategoryRepositories.instance;
  });

  tearDown(() {
    CategoryRepositories.resetInstance();
  });

  group('CategoriesRepositories', () {
    final Icon icon = Icon(Icons.food_bank);
    final Color color = Colors.red;
    final mockData = [
      {'id': 1, 'name': 'Food', 'icon': icon.icon?.codePoint, 'color': color.toARGB32(), 'is_expense': 1, 'position': 0},
      {'id': 2, 'name': 'Salary', 'icon': icon.icon?.codePoint, 'color': color.toARGB32(), 'is_expense': 0, 'position': 1},
    ];

    test('getAllCategories returns a list of Category', () async {
      when(mockDatabase.query('categories', orderBy: 'position ASC'))
          .thenAnswer((_) async => mockData);

      final result = await categoriesRepositories.getAllCategories();

      expect(result, isA<List<Category>>());
      expect(result.length, 2);
      expect(result[0].name, 'Food');
      expect(result[1].name, 'Salary');
    });

    test('getCategoriesByType returns a list of expense categories', () async {
      when(mockDatabase.query(
        'categories',
        where: 'is_expense = ?',
        whereArgs: [1],
        orderBy: 'position ASC',
      )).thenAnswer((_) async => [mockData[0]]);

      final result = await categoriesRepositories.getCategoriesByType(true);

      expect(result, isA<List<Category>>());
      expect(result.length, 1);
      expect(result[0].name, 'Food');
      verify(mockDatabase.query('categories', where: 'is_expense = ?', whereArgs: [1], orderBy: 'position ASC')).called(1);
    });

    test('getCategoriesByType returns a list of income categories', () async {
      when(mockDatabase.query(
        'categories',
        where: 'is_expense = ?',
        whereArgs: [0],
        orderBy: 'position ASC',
      )).thenAnswer((_) async => [mockData[1]]);

      final result = await categoriesRepositories.getCategoriesByType(false);

      expect(result, isA<List<Category>>());
      expect(result.length, 1);
      expect(result[0].name, 'Salary');
      expect(result[0].isExpense, false);
      verify(mockDatabase.query('categories', where: 'is_expense = ?', whereArgs: [0], orderBy: 'position ASC')).called(1);
    });

    test('updatePosition updates the position of a category', () async {
      const categoryId = 1;
      const newPosition = 5;
      final expectedMap = {'position': newPosition};

      when(mockDatabase.update(
        'categories',
        expectedMap,
        where: 'id = ?',
        whereArgs: [categoryId],
      )).thenAnswer((_) async => 1); // Simulate successful update

      await categoriesRepositories.updatePosition(categoryId, newPosition);

      verify(mockDatabase.update(
        'categories',
        expectedMap,
        where: 'id = ?',
        whereArgs: [categoryId],
      )).called(1);
    });

    test('updateCategory updates category name, icon, and color', () async {
      final updatedCategoryData = {
        'id' : 1,
        'name': 'Updated Food',
        'icon': icon.icon?.codePoint,
        'color': color.toARGB32(),
        'is_expense': 1,
        'position': 0,
      };

      when(mockDatabase.update(
        'categories',
        updatedCategoryData,
        where: 'id = ?',
        whereArgs: [1],
      )).thenAnswer((_) async => 1); // Simulate successful update

      await categoriesRepositories.updateCategory(updatedCategoryData, 1);

      verify(mockDatabase.update(
        'categories',
        updatedCategoryData,
        where: 'id = ?',
        whereArgs: [1],
      )).called(1);
    });

    test('deleteCategory deletes a category by id', () async {
      const categoryIdToDelete = 1;

      when(mockDatabase.delete(
        'categories',
        where: 'id = ?',
        whereArgs: [categoryIdToDelete],
      )).thenAnswer((_) async => 1); // Simulate successful deletion

      await categoriesRepositories.deleteCategory(categoryIdToDelete);

      verify(mockDatabase.delete(
        'categories',
        where: 'id = ?',
        whereArgs: [categoryIdToDelete],
      )).called(1);
    });

    test('createCategory inserts a new category', () async {
      final newCategoryData = Category.insertAsMap(name: 'new', position: 2, codePoint: icon.icon!.codePoint, colorValue: color.toARGB32(), isExpense: true);

      when(mockDatabase.insert('categories', newCategoryData))
          .thenAnswer((_) async => 1); // Simulate successful insertion

      await categoriesRepositories.createCategory(newCategoryData);

      verify(mockDatabase.insert('categories', newCategoryData)).called(1);
    });
  });
}