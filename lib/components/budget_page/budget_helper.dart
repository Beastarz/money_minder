import 'package:flutter/material.dart';
import 'package:money_minder/components/budget_page/budget_tile.dart';
import 'package:money_minder/models/currency.dart';

import '../../models/account.dart';
import '../../models/budget.dart';
import '../../models/category.dart';
import '../../models/transaction.dart';
import '../../style/app_color.dart';
import '../../style/app_size.dart';
import '../../utils/show_money.dart';

class BudgetHelper {

  static final Map<String, Color> colorMap = {
    "Expenses": Colors.redAccent,
    "Savings": Colors.orangeAccent,
    "Income": Colors.green,
  };

  static final Map<String, String> textMap = {
    "Expenses": "spent",
    "Savings": "deposited",
    "Income": "received",
  };

  static final List<String> months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ];

  // Function to lighten a color by mixing it with white
  static Color lightenColor(Color color, double factor) {
    // factor: 0.0 means no white, 1.0 means pure white
    return Color.lerp(color, Colors.white, factor)!;
  }

  static Widget buildCatButton(
      void Function()? onPressed,
      String type,
      String currentType,
      Currency mainCurrency,
      double totalAmount,
      double width,
      double leftCurve,
      double rightCurve,
      double factor,
      ) {
    return Expanded(
      child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.all(AppSize.smallPadding),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(AppSize.borderRadius * leftCurve),
                right: Radius.circular(AppSize.borderRadius * rightCurve),
              ),
            ),
            backgroundColor: currentType == type
                ? colorMap[type]
                : lightenColor(colorMap[type]!, 0.9),
          ),
          child: Column(
              spacing: 5,
              children:[
                Text(
                  type,
                  style: TextStyle(
                      fontSize: AppSize.heading3,
                      color: currentType == type
                          ? AppColor.lightText
                          : AppColor.darkText
                  ),
                ),
                ShowMoney(
                  mainCurrency: mainCurrency,
                  amount: totalAmount,
                  text: '',
                  color: currentType == type
                      ? AppColor.lightText
                      : AppColor.darkText,
                  factor: factor,
                  width: width,
                )
              ]
          )
      ),
    );
  }

  static double getCatBudget(List<Budget> budgets, int catId) {
    for (Budget b in budgets) {
      if (b.category!.id == catId) {
        return b.amount;
      }
    }
    return 0;
  }

  static double getAccBudget(List<Budget> budgets, int catId) {
    for (Budget b in budgets) {
      if (b.account!.id == catId) {
        return b.amount;
      }
    }
    return 0;
  }

  static List<Budget> getBudgets(List<Budget> budgets, String type) {
    return budgets.where((budget) => budget.type == type).toList();
  }

  // convert Category to BudgetTileProp
  // result[0]: expenses / income category with expectedAmount == 0
  // result[1]: expenses / income category with expectedAmount != 0
  static List<List<BudgetTileProp>> convertCatToBudgetTileProp(
      List<Category> categories,
      List<Transaction> transactions,
      List<Budget> budgets,
      List<double> totalAmounts,
      bool isExpense,
      Currency mainCurrency
      ) {
    // calculate the total amount of each category
    List<double> amounts = [];
    for (int i = 0; i < categories.length; i++) {
      amounts.add(0);
    }
    String targetType = isExpense ? 'expense' : 'income';
    for (Transaction t in transactions) {
      if (t.type == targetType) {
        int catIndex = t.toCategory!.position;
        amounts[catIndex] += t.mainAmount;
        totalAmounts[isExpense ? 0 : 2] += t.amount;
      }
    }

    // sort the categories according to their position
    categories.sort((a, b) => a.position.compareTo(b.position));

    // convert the categories to CategoryButtonProps
    List<List<BudgetTileProp>> result = [[], []];
    for (int i = 0; i < categories.length; i++) {
      Category category = categories[i];
      double budget = getCatBudget(budgets, category.id);
      result[budget == 0 ? 0 : 1].add(
          BudgetTileProp(
              label: category.label,
              iconData: category.icon.icon,
              color: category.color,
              actualAmount: amounts[category.position],
              budget: budget,
              type: isExpense ? "Expenses" : "Income",
              isCircleBorder: true,
              mainCurrency: mainCurrency
          )
      );
    }
    return result;
  }

  // convert Account to BudgetTileProp
  // result[0]: savings account with expectedAmount == 0
  // result[1]: savings account category with expectedAmount != 0
  static List<List<BudgetTileProp>> convertAccToBudgetTileProp(
      List<Account> accounts,
      List<Transaction> transactions,
      List<Budget> budgets,
      List<double> totalAmounts,
      Currency mainCurrency
      ) {

    // calculate the total amount of each savings
    List<double> amounts = [];
    for (int i = 0; i < accounts.length; i++) {
      amounts.add(0);
    }
    String targetType = 'transfer';
    for (Transaction t in transactions) {
      if (t.type == targetType) {
        bool fromAccIsSavings =
            accounts[t.fromAccount.id - 1].type == AccountType.savings;
        bool toAccIsSavings =
            accounts[t.toAccount!.id - 1].type == AccountType.savings;
        int toSavingsIndex = t.toAccount!.id - 1;
        int fromSavingsIndex = t.fromAccount.id - 1;
        double amount = t.mainAmount;
        if (toAccIsSavings) {
          amounts[toSavingsIndex] += amount;
        }
        if (fromAccIsSavings) {
          amounts[fromSavingsIndex] -= amount;
        }
        totalAmounts[1] += (toAccIsSavings ? amount : 0)
            + (fromAccIsSavings ? -amount : 0);
      }
    }

    // sort the accounts according to their position
    accounts.sort((a, b) => a.position.compareTo(b.position));

    // convert the accounts to BudgetTileProp
    List<List<BudgetTileProp>> result = [[], []];
    for (int i = 0; i < accounts.length; i++) {
      Account account = accounts[i];
      if (account.type != AccountType.savings) {
        continue;
      }
      double budget = getAccBudget(budgets, account.id);
      result[budget == 0 ? 0 : 1].add(
          BudgetTileProp(
              label: account.name,
              iconData: account.icon.icon,
              color: account.color,
              actualAmount: amounts[i],
              budget: budget,
              type: "Savings",
              isCircleBorder: false,
              mainCurrency: mainCurrency
          )
      );
    }

    return result;
  }

  static String generateMonthYearText(DateTime startDate) {
    return '${months[startDate.month - 1]} ${startDate.year}';
  }
}