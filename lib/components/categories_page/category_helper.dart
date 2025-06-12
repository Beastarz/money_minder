import 'package:flutter/material.dart';

import 'package:money_minder/models/category.dart';
import 'package:money_minder/models/date_filter.dart';

import '../../models/budget.dart';
import '../../models/currency.dart';
import '../../models/transaction.dart';
import '../../repositories/categories_repositories.dart';
import '../budget_page/add_budget_sheet.dart';
import '../transaction/add_expense_sheet.dart';
import 'category_button.dart';
import 'category_card.dart';

class CategoryHelper {

  /// get the total budget of all categories in expense or income
  ///
  /// Parameters:
  ///
  /// List<\Budget\> budgets: the list of budgets
  ///
  /// bool isExpense: whether the budget is for expense or income
  ///
  /// return: double
  static double getTotalBudget(List<Budget> budgets, bool isExpense) {
    double amount = 0;
    for (Budget b in budgets) {
      if (b.category.isExpense == isExpense) {
        amount += b.amount;
      }
    }
    return amount;
  }

  /// get the budget of each category
  ///
  /// Parameters:
  ///
  /// List<\Budget\> budgets: the list of budgets
  ///
  /// int catId: the id of the category
  ///
  /// return: double
  static double getBudget(List<Budget> budgets, int catId) {
    double amount = 0;
    for (Budget b in budgets) {
      if (b.category.id == catId) {
        amount += b.amount;
      }
    }
    return amount;
  }

  /// return a lightened color by mixing it with white
  ///
  /// Parameters:
  ///
  /// Color color: the color to be lighten
  ///
  /// double factor: the factor to lighten the color
  ///   (0.0 means no white, 1.0 means pure white)
  ///
  /// return: Color
  static Color lightenColor(Color color, double factor) {
    return Color.lerp(color, Colors.white, factor)!;
  }

  /// convert Category to CategoryButtonProps, sort it with its position
  /// this function also calculates the total amount of expense, income, and each category
  ///
  /// Parameters:
  ///
  /// List\<Category\> categories: the list of categories
  ///
  /// List\<Transaction\> transactions: the list of transactions
  ///
  /// List\<Budget\> budgets: the list of budgets
  ///
  /// List\<double\> totalAmounts: the list of total amounts ([expense total amount, income total amount])
  ///
  /// bool isExpense: whether the budget is for expense or income
  ///
  /// DateFilter dateFilter: the date filter
  ///
  /// return: List\<CategoryProp\>
  static List<CategoryProp> convertToCatButProps(
      List<Category> categories,
      List<Transaction> transactions,
      List<Budget> budgets,
      List<double> totalAmounts,
      bool isExpense,
      DateFilter dateFilter
      ) {

    // for (Category c in categories) {
    //   print("${c.label} ${c.position}");
    // }

    // calculate the total amount of each category
    List<double> amounts = [];
    for (int i = 0; i < categories.length; i++) {
      amounts.add(0);
    }
    TransactionType targetType =
      isExpense ? TransactionType.expense : TransactionType.income;
    for (int i = 0; i < transactions.length; i++) {
      Transaction t = transactions[i];
      if (t.type == targetType) {
        amounts[t.toCategory!.position] += t.mainAmount;
        totalAmounts[isExpense ? 0 : 1] += t.mainAmount;
      }
    }

    // convert the categories to CategoryButtonProps
    List<CategoryProp> result = [];
    for (int i = 0; i < categories.length; i++) {
      Category category = categories[i];
      double budget = getBudget(budgets, category.id);
      result.add(
        CategoryProp(
            id: category.id,
            position: category.position,
            label: category.label,
            icon: category.icon,
            color: category.color,
            actualAmount: amounts[i],
            budget: budget,
            isExpense: category.isExpense)
      );
    }

    for (CategoryProp c in result) {
      if (c.actualAmount == 0) {
        continue;
      }
    }
    return result;
  }

  /// show the transaction input form when the add transaction button is pressed
  ///
  /// Parameters:
  ///
  /// BuildContext context: the context of the page
  ///
  /// Currency mainCurrency: the main currency of the app
  ///
  /// void Function() reload: the function to reload the transaction
  ///
  /// return: void
  static void Function(CategoryProp) showTransactionInputForm(
      BuildContext context, Currency mainCurrency, void Function() reload) {
    return (CategoryProp prop) {
      showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (sheetContext) {
            return EditExpenseSheet(
              mainCurrency: mainCurrency,
              toCategory: Category(
                  id: prop.id,
                  label: prop.label,
                  position: prop.position,
                  icon: prop.icon,
                  color: prop.color,
                  isExpense: prop.isExpense
              ),
              onAddTransactionReload: reload,
            );
          }
      );
    };
  }

  /// show the budget input form when the add budget button is pressed
  ///
  /// Parameters:
  ///
  /// BuildContext context: the context of the page
  ///
  /// Currency mainCurrency: the main currency of the app
  ///
  /// DateTime startDate: the start date of this period
  ///
  /// void Function() reload: the function to reload the budget
  ///
  /// return: void
  static void Function(CategoryProp) showBudgetInputForm(BuildContext context,
      Currency mainCurrency, DateTime startDate, void Function() reload
      ) {

    return (CategoryProp prop) {
      showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (sheetContext) {
            return AddBudgetSheet(
              prop: prop,
              mainCurrency: mainCurrency,
              startDate: startDate,
              onBudgetReload: reload,
            );
          }
      );
    };
  }

  /// show the Category Card on the Category Page and Statistics Page
  ///
  /// Parameters:
  ///
  /// BuildContext context: the context of the page
  ///
  /// CategoryProp prop: the category to be shown
  ///
  /// Currency mainCurrency: the main currency of the app
  ///
  /// DateTime startDate: the start date of this period
  ///
  /// bool disabledAddBudget: whether the add budget button is disabled
  ///
  /// void Function() reloadTransaction: the function to reload the transaction
  ///
  /// void Function() reloadBudget: the function to reload the budget
  ///
  /// return: void
  static void showCategoryCard(
      BuildContext context, CategoryProp prop, Currency mainCurrency, DateTime startDate,
      bool disabledAddBudget, void Function() reloadTransaction, void Function() reloadBudget) {
    showDialog(
      context: context,
      builder: (context) {
        return CategoryCard(
          prop: prop,
          currency: mainCurrency,
          disabledAddBudget: disabledAddBudget,
          showTransactionInputForm: showTransactionInputForm(
              context, mainCurrency, reloadTransaction),
          showBudgetInputForm: showBudgetInputForm(
              context, mainCurrency, startDate, reloadBudget),
        );
      },
    );
  }

  /// get the ids of the categories from the positions
  ///
  /// Parameters:
  ///
  /// int fromPosition: the position of the first category
  ///
  /// int toPosition: the position of the last category
  ///
  /// List\<CategoryProp\> categories: the list of categories
  ///
  /// return: List\<int\>
  static List<int> getIdsFromPositions(
      int fromPosition, int toPosition, List<CategoryProp> categories) {
    List<int> ids = [];
    for (int i = fromPosition; i <= toPosition; i++) {
      ids.add(categories[i].id);
    }
    return ids;
  }

  /// move all the categories in between fromPosition and toPosition
  ///
  /// Parameters:
  ///
  /// int fromPosition: the position of the first category
  ///
  /// int toPosition: the position of the last category
  ///
  /// List\<CategoryProp\> categories: the list of categories
  ///
  /// return: void
  static Future<void> movePosition(int fromPosition, int toPosition, List<CategoryProp> categories) async {
    if (fromPosition > toPosition) {
      // bring the item at the back to the front

      List<int> ids = getIdsFromPositions(toPosition, fromPosition, categories);

      // set the position of the last category to the first
      await CategoriesRepositories.instance.updatePosition(
          ids.last, toPosition);

      // add the position of the remaining categories by 1
      for (int i = toPosition + 1; i <= fromPosition; i++) {
        await CategoriesRepositories.instance.updatePosition(
            ids[i - toPosition - 1], i);
      }
    } else {

      // bring the item at the front to the back

      List<int> ids = getIdsFromPositions(fromPosition, toPosition, categories);

      // set the position of the last category to the first
      await CategoriesRepositories.instance.updatePosition(
          ids.first, toPosition);

      // add the position of the remaining categories by 1
      for (int i = fromPosition + 1; i <= toPosition; i++) {
        await CategoriesRepositories.instance.updatePosition(
            ids[i - fromPosition], i - 1);
      }
    }
  }
}