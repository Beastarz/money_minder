import 'package:flutter/material.dart';

import 'package:money_minder/models/category.dart';
import 'package:money_minder/models/date_filter.dart';

import '../../models/budget.dart';
import '../../models/transaction.dart';
import 'category_button.dart';

class CategoryHelper {

  static double getBudget(List<Budget> budgets, int catId) {
    double amount = 0;
    for (Budget b in budgets) {
      if (b.category.id == catId) {
        amount += b.amount;
      }
    }
    return amount;
  }

  // Function to lighten a color by mixing it with white
  static Color lightenColor(Color color, double factor) {
    // factor: 0.0 means no white, 1.0 means pure white
    return Color.lerp(color, Colors.white, factor)!;
  }

  // convert Category to CategoryButtonProps
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
}