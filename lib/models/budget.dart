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

  /// use this to convert map to budget
  ///
  /// Parameters:
  ///
  /// Map\<String, dynamic\> map: map to be converted
  ///
  /// Category category: category of the budget
  ///
  /// Returns: Budget
  factory Budget.fromMap(Map<String, dynamic> map, Category category) {
    return Budget(
      id: map['id'],
      amount: map['amount'],
      month: map['month'],
      year: map['year'],
      category: category,
    );
  }

  /// use this to convert budget to map
  ///
  /// Parameters:
  ///
  /// double budget: budget to be converted
  ///
  /// int month: month of the budget
  ///
  /// int year: year of the budget
  ///
  /// int categoryId: category id of the budget
  ///
  /// Returns: map of budget
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

  /// Use this to group transactions by date.
  ///
  /// If date filter type is month, then group by month.
  /// If date filter type is year, add all budgets in the same year.
  /// If date filter type is all, don't have budget.
  /// For all other cases, group by the period depending on the budget of the month
  /// which the startDate falls in.
  ///
  /// Parameters:
  ///
  /// List\<Budget\> budgets: list of budgets to be grouped
  ///
  /// DateFilter dateFilter: date filter to be used for grouping
  ///
  /// Returns: list of lists of budgets grouped by date
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
