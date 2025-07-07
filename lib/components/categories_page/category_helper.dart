import 'package:flutter/material.dart';

import 'package:money_minder/models/category.dart';
import 'package:money_minder/models/date_filter.dart';

import '../../models/budget.dart';
import '../../models/currency.dart';
import '../../models/transaction.dart';
import '../../repositories/categories_repositories.dart';
import '../../style/app_color.dart';
import '../../style/app_size.dart';
import '../budget_page/add_budget_sheet.dart';
import '../transaction/add_expense_sheet.dart';
import 'add_category_page.dart';
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
            label: category.name,
            icon: category.icon,
            color: category.color,
            actualAmount: amounts[i],
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
      BuildContext context, Currency mainCurrency, DateTime defaultDate, void Function() reload) {
    return (CategoryProp prop) {
      showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (sheetContext) {
            return AddExpenseSheet(
              mainCurrency: mainCurrency,
              toCategory: Category(
                  id: prop.id,
                  name: prop.label,
                  position: prop.position,
                  icon: prop.icon,
                  color: prop.color,
                  isExpense: prop.isExpense
              ),
              defaultDate: defaultDate,
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
      Currency mainCurrency, DateTime startDate, void Function() reload, bool disabledDelete
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
              disabledDelete: disabledDelete
            );
          }
      );
    };
  }

  static void Function(CategoryProp) showAddCategoryPage(
      BuildContext context,
      List<CategoryProp> props,
      Future<void> Function() onCategoryReload,
      Future<void> Function() onTransactionReload,
      Future<void> Function() onBudgetReload) {
    return (CategoryProp prop) {
      showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) =>
              SafeArea(
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSize.borderRadius)),
                      color: AppColor.secondary,
                    ),
                    child: AddCategoryPage(
                      prop: prop,
                      categories: props,
                      onCategoryReload: onCategoryReload,
                      onTransactionReload: onTransactionReload,
                      onBudgetReload: onBudgetReload,
                    )
                ),
              )
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
      DateTime defaultDateForTransaction, bool disabledAddBudget,
      Future<void> Function() reloadTransaction, Future<void> Function() reloadBudget,
      void Function(int) showCategoryTransactions, {List<CategoryProp> props = const [],
      bool disabledEditCategory = true, Future<void> Function()? reloadCategory}) {
    showDialog(
      context: context,
      builder: (context) {
        return CategoryCard(
          prop: prop,
          currency: mainCurrency,
          disabledAddBudget: disabledAddBudget,
          showCategoryTransactions: showCategoryTransactions,
          showTransactionInputForm: showTransactionInputForm(
              context, mainCurrency, defaultDateForTransaction, reloadTransaction),
          showBudgetInputForm: showBudgetInputForm(
              context, mainCurrency, startDate, reloadBudget, prop.budget == 0),
          showAddCategoryPage: disabledEditCategory
              ? null
              : showAddCategoryPage(context, props, reloadCategory!, reloadTransaction, reloadBudget),
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

  /// add new Category
  ///
  /// Parameters:
  ///
  /// int position: the position of the new category
  ///
  /// String label: the label of the new category
  ///
  /// int codePoint: the icon's code point of the new category
  ///
  /// int colorValue: the color's value of the new category
  ///
  /// bool isExpense: whether the new category is for expense or income
  ///
  /// return: void
  static Future<void> addCategory(int position, String label, int codePoint,
    int colorValue, bool isExpense) async {
    await CategoriesRepositories.instance.createCategory(
      Category.insertAsMap(
        name: label,
        position: position,
        codePoint: codePoint,
        colorValue: colorValue,
        isExpense: isExpense,
      )
    );
  }

  /// update existing category
  static Future<void> updateCategory(int id, String label, int codePoint, int colorValue, bool isExpense) async {
    await CategoriesRepositories.instance.updateCategory(
        {
          'label': label,
          'icon': codePoint,
          'color': colorValue,
          'is_expense': isExpense ? 1 : 0,
        },
      id
    );
  }

  /// delete existing category by id
  static Future<void> deleteCategory(int id, int position, List<CategoryProp> categories) async {
    await movePosition(position, categories.length - 2, categories); // swap with second last in the list (include add button)
    await CategoriesRepositories.instance.deleteCategory(id); // currently at the last of the array
  }
}