import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/material.dart';
import 'package:money_minder/models/budget.dart';
import 'package:money_minder/models/category.dart';
import 'package:money_minder/repositories/budget_repositories.dart';
import 'package:money_minder/repositories/category_repositories.dart';

import 'test.mocks.dart';


void main() {
  late BudgetRepositories budgetRepositories;
  late MockDatabaseService mockDbService;
  late MockDatabase mockDatabase;
  late MockCategoriesRepositories mockCategoriesRepositories;

  setUp(() {
    mockDbService = MockDatabaseService();
    mockDatabase = MockDatabase();
    mockCategoriesRepositories = MockCategoriesRepositories();

    when(mockDbService.database).thenAnswer((_) async => mockDatabase);

    BudgetRepositories.setMockDbService(mockDbService);
    budgetRepositories = BudgetRepositories.instance;

    CategoryRepositories.setTestInstance(mockCategoriesRepositories);
  });

  tearDown(() {
    BudgetRepositories.resetInstance();
    CategoryRepositories.resetInstance();
  });

  group('BudgetRepositories', () {
    final Icon icon = Icon(Icons.add);
    final Color color = Colors.red;
    final mockCategories = [
      Category(id: 1, name: 'Food', icon: icon, color: color, isExpense: true, position: 0),
      Category(id: 2, name: 'Salary', icon: icon, color: color, isExpense: false, position: 2),
    ];
    final mockBudgetMaps = [
      {'id': 1, 'category_id': 1, 'amount': 200.0, 'month': 6, 'year': 2025},
      {'id': 2, 'category_id': 2, 'amount': 100.0, 'month': 6, 'year': 2025},
    ];

    test('getBudgets returns a list of Budget objects with linked categories', () async {
      when(mockCategoriesRepositories.getAllCategories()).thenAnswer((_) async => mockCategories);
      when(mockDatabase.query('budgets')).thenAnswer((_) async => mockBudgetMaps);

      final result = await budgetRepositories.getBudgets();

      expect(result, isA<List<Budget>>());
      expect(result.length, 2);

      // Verify the first budget
      expect(result[0].id, 1);
      expect(result[0].amount, 200.0);
      expect(result[0].category.id, 1);
      expect(result[0].category.name, 'Food');

      // Verify the second budget
      expect(result[1].id, 2);
      expect(result[1].amount, 100.0);
      expect(result[1].category.id, 2);
      expect(result[1].category.name, 'Salary');

      verify(mockCategoriesRepositories.getAllCategories()).called(1);
      verify(mockDatabase.query('budgets')).called(1);
    });

    test('getBudget returns the correct amount if found', () async {
      final mockBudgetResult = [
        {'id': 1, 'category_id': 1, 'amount': 250.0, 'month': 7, 'year': 2025},
      ];

      when(mockDatabase.query(
        'budgets',
        where: 'month = ? AND year = ? AND category_id = ?',
        whereArgs: [7, 2025, 1],
      )).thenAnswer((_) async => mockBudgetResult);

      final result = await budgetRepositories.getBudget(7, 2025, 1);

      expect(result, 250.0);
      verify(mockDatabase.query(
        'budgets',
        where: 'month = ? AND year = ? AND category_id = ?',
        whereArgs: [7, 2025, 1],
      )).called(1);
    });

    test('getBudget returns 0.0 if budget not found', () async {
      when(mockDatabase.query(
        'budgets',
        where: 'month = ? AND year = ? AND category_id = ?',
        whereArgs: [7, 2025, 99],
      )).thenAnswer((_) async => []); // Empty list for not found

      final result = await budgetRepositories.getBudget(7, 2025, 99);

      expect(result, 0.0);
      verify(mockDatabase.query(
        'budgets',
        where: 'month = ? AND year = ? AND category_id = ?',
        whereArgs: [7, 2025, 99],
      )).called(1);
    });

    test('getBudgetId returns the correct id if found', () async {
      final mockIdResult = [
        {'id': 5, 'category_id': 1, 'amount': 250.0, 'month': 7, 'year': 2025},
      ];

      when(mockDatabase.query(
        'budgets',
        where: 'month = ? AND year = ? AND category_id = ?',
        whereArgs: [7, 2025, 1],
      )).thenAnswer((_) async => mockIdResult);

      final result = await budgetRepositories.getBudgetId(7, 2025, 1);

      expect(result, 5);
      verify(mockDatabase.query(
        'budgets',
        where: 'month = ? AND year = ? AND category_id = ?',
        whereArgs: [7, 2025, 1],
      )).called(1);
    });

    test('getBudgetId returns 0 if budget not found', () async {
      when(mockDatabase.query(
        'budgets',
        where: 'month = ? AND year = ? AND category_id = ?',
        whereArgs: [7, 2025, 99],
      )).thenAnswer((_) async => []); // Empty list for not found

      final result = await budgetRepositories.getBudgetId(7, 2025, 99);

      expect(result, 0);
      verify(mockDatabase.query(
        'budgets',
        where: 'month = ? AND year = ? AND category_id = ?',
        whereArgs: [7, 2025, 99],
      )).called(1);
    });

    test('createBudget inserts a new budget', () async {
      final newBudgetMap = Budget.insertAsMap(amount: 100.0, month: 6, year: 2025, currency: "SGD", categoryId: 1);

      when(mockDatabase.insert('budgets', newBudgetMap))
          .thenAnswer((_) async => 1); // Simulate successful insertion

      await budgetRepositories.createBudget(newBudgetMap);

      verify(mockDatabase.insert('budgets', newBudgetMap)).called(1);
    });

    test('updateBudget updates an existing budget', () async {
      const budgetId = 1;
      final updatedBudgetMap = {
        'category_id': 1,
        'amount': 300.0,
        'month': 6,
        'year': 2025,
      };

      when(mockDatabase.update(
        'budgets',
        updatedBudgetMap,
        where: 'id = ?',
        whereArgs: [budgetId],
      )).thenAnswer((_) async => 1); // Simulate successful update

      await budgetRepositories.updateBudget(updatedBudgetMap, budgetId);

      verify(mockDatabase.update(
        'budgets',
        updatedBudgetMap,
        where: 'id = ?',
        whereArgs: [budgetId],
      )).called(1);
    });

    test('deleteBudget deletes a budget by month, year, and categoryId', () async {
      const monthToDelete = 6;
      const yearToDelete = 2025;
      const categoryIdToDelete = 1;

      when(mockDatabase.delete(
        'budgets',
        where: 'year = ? AND month = ? AND category_id = ?',
        whereArgs: [yearToDelete, monthToDelete, categoryIdToDelete],
      )).thenAnswer((_) async => 1); // Simulate successful deletion

      await budgetRepositories.deleteBudget(monthToDelete, yearToDelete, categoryIdToDelete);

      verify(mockDatabase.delete(
        'budgets',
        where: 'year = ? AND month = ? AND category_id = ?',
        whereArgs: [yearToDelete, monthToDelete, categoryIdToDelete],
      )).called(1);
    });

    test('deleteBudgetById deletes all budgets for a given categoryId', () async {
      const categoryIdToDelete = 5;

      when(mockDatabase.delete(
        'budgets',
        where: 'category_id = ?',
        whereArgs: [categoryIdToDelete],
      )).thenAnswer((_) async => 3); // Simulate deleting 3 rows

      await budgetRepositories.deleteBudgetById(categoryIdToDelete);

      verify(mockDatabase.delete(
        'budgets',
        where: 'category_id = ?',
        whereArgs: [categoryIdToDelete],
      )).called(1);
    });
  });
}