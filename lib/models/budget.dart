import 'package:money_minder/models/category.dart';
import 'package:money_minder/models/date_filter.dart';

class Budget {
  final int id;
  final double amount;
  final int month;
  final int year;
  final Category category;

  const Budget({
    required this.id,
    required this.amount,
    required this.month,
    required this.year,
    required this.category,
  });

  /// use this to convert map to transaction
  factory Budget.fromMap(Map<String, dynamic> map, Category category) {
    return Budget(
      id: map['id'],
      amount: map['amount'],
      month: map['month'],
      year: map['year'],
      category: category,
    );
  }

  static Map<String, dynamic> insertAsMap({
    required double amount,
    required int month,
    required int year,
    required int categoryId,
  }) {
    return {
      'amount': amount,
      'month': month,
      'year': year,
      'category_id': categoryId,
    };
  }

  /// use this to group transactions by date
  // if date filter type is month, then group by month
  // if date filter type is year, add all budgets in the same year
  // if date filter type is all, don't have budget
  // for all other cases, group by the period depending on the budget of the month
  // which the startDate falls in.
  static List<List<Budget>> groupBudgetsByDate(List<Budget> budgets, DateFilter dateFilter) {
    List<DateTime> startDates = dateFilter.startDates;
    DateFilterType dateFilterType = dateFilter.type;
    List<List<Budget>> groupedBudgets = [];
    if (dateFilterType == DateFilterType.all) {

      // add empty list for each date filter
      for (int i = 0; i < startDates.length - 2 ; i++) {
        groupedBudgets.add([]);
      }
      groupedBudgets.insert(50, budgets);
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
            month: budget.month,
            year: budget.year,
            category: budget.category,
            )
          )
          .toList());
      }
    }
    return groupedBudgets;
  }
}
