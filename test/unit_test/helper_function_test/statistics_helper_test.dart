import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_minder/components/categories_page/category_button.dart';
import 'package:money_minder/components/statistics_page/statistics_helper.dart';
import 'package:money_minder/models/account.dart';
import 'package:money_minder/models/category.dart';
import 'package:money_minder/models/currency.dart';
import 'package:money_minder/models/transaction.dart';
import 'package:money_minder/models/date_filter.dart';

void main() {
  group('StatisticsHelper', () {
    final Currency myr = Currency.of("MYR");

    final Category foodCategory = Category(
      id: 1,
      name: 'Food',
      icon: Icon(Icons.fastfood),
      color: Colors.red,
      position: 0,
      isExpense: true,
    );

    final Account mainAccount = Account(
      id: 1,
      name: 'Main Wallet',
      balance: 1000.0,
      icon: Icon(Icons.account_balance_wallet),
      color: Colors.blue,
      description: 'Main cash account',
      isMain: true,
      isIncludesInTotal: true,
      type: AccountType.accounts,
      currency: myr,
      position: 0,
    );

    final List<CategoryProp> categoryProps = [
      CategoryProp(
        id: 1,
        position: 0,
        label: 'Food',
        icon: Icon(Icons.fastfood),
        color: Colors.red,
        actualAmount: 200.0,
        budget: 500.0,
        isExpense: true,
      ),
      CategoryProp(
        id: 2,
        position: 1,
        label: 'Transport',
        icon: Icon(Icons.directions_car),
        color: Colors.green,
        actualAmount: 150.0,
        budget: 300.0,
        isExpense: true,
      ),
    ];

    final List<Transaction> transactions = [
      Transaction(
        id: 1,
        date: DateTime(2025, 7, 10),
        type: TransactionType.expense,
        fromAccount: mainAccount,
        toAccount: null,
        toCategory: foodCategory,
        amount: 100,
        currency: myr,
        mainCurrency: myr,
        note: 'Lunch',
      ),
      Transaction(
        id: 2,
        date: DateTime(2025, 7, 11),
        type: TransactionType.expense,
        fromAccount: mainAccount,
        toAccount: null,
        toCategory: foodCategory,
        amount: 100,
        currency: myr,
        mainCurrency: myr,
        note: 'Dinner',
      ),
    ];

    test('getTotalAmount should return correct sum', () {
      final result = StatisticsHelper.getTotalAmount(transactions);
      expect(result, 200.0);
    });

    test('calculatePercentages should normalize correctly', () {
      final result = StatisticsHelper.calculatePercentages(categoryProps, 350.0);
      expect(result.length, 2);
      expect(result[0], 1.0); // 200/350 = max
      expect(result[1], closeTo(150 / 200, 0.001)); // normalized to max
    });

    test('sortCategories should sort alphabetically ascending', () {
      final sorted = List<CategoryProp>.from(categoryProps);
      StatisticsHelper.sortCategories(sorted, true, SortOptions.alphabetical, 0);
      expect(sorted.first.label, 'Food');
      expect(sorted.last.label, 'Transport');
    });

    test('compressData reduces list correctly', () {
      final longList = List.generate(
        5,
            (i) => CategoryProp(
          id: i,
          position: i,
          label: 'Cat $i',
          icon: Icon(Icons.category),
          color: Colors.grey,
          actualAmount: 10.0,
          budget: 0.0,
          isExpense: true,
        ),
      );
      final result = StatisticsHelper.compressData(longList, 3);
      expect(result.length, 3);
      expect(result.last.label, 'Others');
      expect(result.last.actualAmount, 20.0);
    });

    test('slicePeriod returns correct date slices for month expanded', () {
      final result = StatisticsHelper.slicePeriod(
        DateTime(2025, 7, 1),
        DateTime(2025, 7, 31),
        true,
        DateFilterType.month,
      );
      expect(result.length, 5); // start + 3 slices + end
    });

    test('categorizeTransactions correctly groups transactions', () {
      final categorized = StatisticsHelper.categorizeTransactions(transactions, categoryProps);
      expect(categorized.length, 2);
      expect(categorized[0].length, 2); // Food
      expect(categorized[1].length, 0); // Transport
    });
  });
}
