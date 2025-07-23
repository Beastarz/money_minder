import '../../models/budget.dart';
import '../../repositories/budget_repositories.dart';

class BudgetHelper {

  /// add or update budget, if budget doesn't exist, create it
  ///
  /// Parameters:
  ///
  /// DateTime date: date of budget
  ///
  /// double amount: amount of budget
  ///
  /// int categoryId: id of category
  ///
  /// return: void
  static Future<void> addBudget(DateTime date, double amount, int categoryId, String currency) async {
    int month = date.month;
    int year = date.year;

    // id will be 0 if budget doesn't exist
    int id = await BudgetRepositories.instance.getBudgetId(
        month, year, categoryId
    );

    // budget model to be inserted
    Map<String, dynamic> budget = Budget.insertAsMap(
        amount: amount,
        month: month,
        year: year,
        currency: currency,
        categoryId: categoryId,
    );

    if (id != 0) {
      // update budget
      await BudgetRepositories.instance.updateBudget(budget, id);
    } else {
      // create budget
      await BudgetRepositories.instance.createBudget(budget);
    }
  }
}