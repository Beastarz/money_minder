import 'package:money_minder/models/category.dart';
import 'package:money_minder/models/date_filter.dart';

import 'account.dart';
class Budget {
  final int id;
  final double amount;
  final String type;
  final int month;
  final int year;
  final Category? category;
  final Account? account;

  const Budget({
    required this.id,
    required this.amount,
    required this.type,
    required this.month,
    required this.year,
    required this.category,
    required this.account,
  });

  /// use this to convert map to transaction
  factory Budget.fromMap(Map<String, dynamic> map, Category? category, Account? account) {
    return Budget(
      id: map['id'],
      amount: map['amount'],
      type: map['type'],
      month: map['month'],
      year: map['year'],
      category: category,
      account: account,
    );
  }

  static Map<String, dynamic> insertAsMap({
    required double amount,
    required String type,
    required int month,
    required int year,
    required int categoryId,
    required int accountId,
  }) {
    return {
      'amount': amount,
      'type': type,
      'month': month,
      'year': year,
      'category_id': categoryId,
      'account_id': accountId,
    };
  }

  /// use this to group transactions by date
  // if dateFiltertype is month, then group by month
  // if dateFiltertype is year, add all budgets in the same year
  // if dateFiltertype is all, don't have budget
  // for all other cases, group by the period depending on the budget of the month
  // which the startDate falls in.
  static List<List<Budget>> groupBudgetsByDate(List<Budget> budgets, DateFilter dateFilter) {
    List<DateTime> startDates = dateFilter.startDates;
    DateFilterType dateFilterType = dateFilter.type;
    List<List<Budget>> groupedBudgets = [];
    if (dateFilterType == DateFilterType.all) {

      // add empty list for each date filter
      for (int i = 0; i < startDates.length - 1 ; i++) {
        groupedBudgets.add([]);
      }
    } else if (dateFilterType == DateFilterType.year) {

      // add all budgets in the same year
      for (int i = 0; i < startDates.length - 1 ; i++) {
        groupedBudgets.add(budgets.where((budget) =>
          budget.year == startDates[i].year
        ).toList());
      }
    } else if (dateFilterType == DateFilterType.month) {

      // add all budgets in the same month
      for (int i = 0; i < startDates.length - 1 ; i++) {
        groupedBudgets.add(budgets.where((budget) =>
          budget.year == startDates[i].year && budget.month == startDates[i].month
        ).toList());
      }
    } else {

      // add all budgets in the same period, depending on the month of start date
      // int periodInDays = dateFilter.duration!.inDays;
      int periodInDays = startDates[1].difference(startDates[0]).inDays;
      for (int i = 0; i < startDates.length - 1 ; i++) {
        groupedBudgets.add(budgets
          .where((budget) =>
            budget.year == startDates[i].year && budget.month == startDates[i].month
          )
          .map((budget) => Budget(
            id: budget.id,
            amount: budget.amount * (periodInDays / 30),
            type: budget.type,
            month: budget.month,
            year: budget.year,
            account: budget.account,
            category: budget.category,
            )
          )
          .toList());
      }
    }
    return groupedBudgets;
  }
}
