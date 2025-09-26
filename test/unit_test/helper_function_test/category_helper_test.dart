import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_minder/components/categories_page/category_helper.dart';
import 'package:money_minder/models/budget.dart';
import 'package:money_minder/models/category.dart';
import 'package:money_minder/models/currency.dart';

void main() {
  group('CategoryHelper', () {
    late Currency mainCurrency;
    late Currency usd;
    late Category foodCategory;
    late Category transportCategory;

    setUp(() {
      mainCurrency = Currency.of("MYR");
      usd = Currency.of("USD");

      foodCategory = Category(
        id: 1,
        name: 'Food',
        position: 0,
        icon: const Icon(Icons.fastfood),
        color: Colors.red,
        isExpense: true,
      );

      transportCategory = Category(
        id: 2,
        name: 'Transport',
        position: 1,
        icon: const Icon(Icons.directions_bus),
        color: Colors.blue,
        isExpense: true,
      );
    });

    test('getTotalBudget returns correct total for matching isExpense', () {
      final budgets = [
        Budget(id: 1, amount: 10, month: 7, year: 2025, category: foodCategory, currency: mainCurrency),
        Budget(id: 2, amount: 20, month: 7, year: 2025, category: transportCategory, currency: usd),
        Budget(id: 3, amount: 15, month: 7, year: 2025, category: foodCategory, currency: usd),
      ];

      final total = CategoryHelper.getTotalBudget(budgets, true, mainCurrency);
      expect(total, 10 + Currency.convert(usd, mainCurrency, 20 + 15));
    });

    test('getTotalBudget returns 0 for non-matching isExpense', () {
      final incomeCategory = Category(
        id: 3,
        name: 'Salary',
        position: 2,
        icon: const Icon(Icons.monetization_on),
        color: Colors.green,
        isExpense: false,
      );

      final budgets = [
        Budget(id: 1, amount: 1000, month: 7, year: 2025, category: incomeCategory, currency: mainCurrency),
      ];

      final total = CategoryHelper.getTotalBudget(budgets, true, mainCurrency);
      expect(total, 0);
    });

    test('getBudget returns correct total for specific category', () {
      final budgets = [
        Budget(id: 1, amount: 10, month: 7, year: 2025, category: foodCategory, currency: usd),
        Budget(id: 2, amount: 20, month: 7, year: 2025, category: transportCategory, currency: mainCurrency),
        Budget(id: 3, amount: 5,  month: 7, year: 2025, category: foodCategory, currency: mainCurrency),
      ];

      final totalFood = CategoryHelper.getBudget(budgets, foodCategory.id, mainCurrency);
      expect(totalFood, Currency.convert(usd, mainCurrency, 10) + 5);

      final totalTransport = CategoryHelper.getBudget(budgets, transportCategory.id, mainCurrency);
      expect(totalTransport, 20);
    });

    test('lightenColor returns a lighter color', () {
      final original = Colors.red;
      final lighter = CategoryHelper.lightenColor(original, 0.3);
      expect(lighter.computeLuminance(), greaterThan(original.computeLuminance()));
    });
  });
}
