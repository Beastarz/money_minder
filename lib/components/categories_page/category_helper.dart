import 'package:flutter/material.dart';

import 'package:money_minder/models/category.dart';
import 'package:money_minder/models/date_filter.dart';

import '../../models/budget.dart';
import '../../models/currency.dart';
import '../../models/transaction.dart';
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

    // calculate the total amount of each category
    List<double> amounts = [];
    for (int i = 0; i < categories.length; i++) {
      amounts.add(0);
    }
    TransactionType targetType =
      isExpense ? TransactionType.expense : TransactionType.income;
    for (Transaction t in transactions) {
      if (t.type == targetType) {
        int catIndex = t.toCategory!.position;
        amounts[catIndex] += t.mainAmount;
        totalAmounts[isExpense ? 0 : 1] += t.mainAmount;
      }
    }

    // sort the categories according to their position
    categories.sort((a, b) => a.position.compareTo(b.position));

    // convert the categories to CategoryButtonProps
    List<CategoryProp> result = [];
    // final double coefficient = getBudgetCoefficient(dateFilter);
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
            actualAmount: amounts[category.position],
            budget: budget,
            isExpense: category.isExpense)
      );
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
}