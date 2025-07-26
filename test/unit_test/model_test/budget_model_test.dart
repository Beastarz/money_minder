import 'package:flutter_test/flutter_test.dart';
import 'package:money_minder/models/budget.dart';
import 'package:money_minder/models/category.dart';
import 'package:money_minder/models/currency.dart';
import 'package:money_minder/models/date_filter.dart';
import 'package:flutter/material.dart';

void main() {
  group('Budget model', () {
    final testCategory = Category(
      id: 1,
      name: 'Food',
      position: 0,
      icon: const Icon(Icons.fastfood),
      color: Colors.red,
      isExpense: true,
    );

    test('fromMap creates a valid Budget object', () {
      final map = {
        'id': 10,
        'amount': 150.0,
        'month': 7,
        'year': 2025,
        'currency': 'MYR',
      };

      final budget = Budget.fromMap(map, testCategory);

      expect(budget.id, 10);
      expect(budget.amount, 150.0);
      expect(budget.month, 7);
      expect(budget.year, 2025);
      expect(budget.currency, Currency.of('MYR'));
      expect(budget.category.name, 'Food');
    });

    test('insertAsMap returns correct map structure', () {
      final map = Budget.insertAsMap(
        amount: 200.0,
        month: 7,
        year: 2025,
        currency: 'SGD',
        categoryId: 3,
      );

      expect(map['amount'], 200.0);
      expect(map['month'], 7);
      expect(map['year'], 2025);
      expect(map['currency'], 'SGD');
      expect(map['category_id'], 3);
    });

    test('groupBudgetsByDate groups by year correctly', () {
      final budgets = [
        Budget(id: 1, amount: 100, month: 1, year: DateTime.now().year, category: testCategory, currency: Currency.of('SGD')),
        Budget(id: 2, amount: 200, month: 5, year: DateTime.now().year, category: testCategory, currency: Currency.of('SGD')),
        Budget(id: 3, amount: 300, month: 3, year: DateTime.now().year - 1, category: testCategory, currency: Currency.of('SGD')),
      ];

      final filter = DateFilter.fromType(DateFilterType.year);

      final grouped = Budget.groupBudgetsByDate(budgets, filter);

      expect(grouped.length, 101); // group length will always be 101
      expect(grouped[49].length, 1); // last year
      expect(grouped[50].length, 2); // this year
    });

    test('groupBudgetsByDate with type "all" places all budgets in one group', () {
      final budgets = [
        Budget(id: 1, amount: 100, month: 1, year: 2024, category: testCategory, currency: Currency.of('SGD')),
        Budget(id: 2, amount: 150, month: 6, year: 2025, category: testCategory, currency: Currency.of('SGD')),
      ];

      final filter = DateFilter.fromType(DateFilterType.all);

      final grouped = Budget.groupBudgetsByDate(budgets, filter);

      expect(grouped.length, 101); // group length will always be 101
      expect(grouped[50].length, 2); // add all budgets in one group, 2 budget in this case
    });
  });
}
