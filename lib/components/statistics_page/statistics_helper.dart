import 'package:flutter/material.dart';

import '../categories_page/category_button.dart';

enum SortOptions {
  alphabetical,
  budget,
  actualAmount,
  position,
  percentage,
}

class StatisticsHelper {

  static final Map<SortOptions, Icon> sortOptionIcon= {
    SortOptions.alphabetical: Icon(Icons.sort_by_alpha),
    SortOptions.budget: Icon(Icons.receipt_long),
    SortOptions.actualAmount: Icon(Icons.monetization_on_outlined),
    SortOptions.position: Icon(IconData(0xf20c, fontFamily: "MaterialSymbolsOutlined")),
    SortOptions.percentage: Icon(Icons.percent),
  };

  /// Helper method to get and sort the category list
  ///
  /// Parameters:
  ///
  /// List\<CategoryProp\> category: the list of categories
  ///
  /// bool ascending: whether the list is sorted in ascending order
  ///
  /// SortOptions option: the option to sort the list
  ///
  /// return: void
  static void sortCategories(

      List<CategoryProp> category, bool ascending, SortOptions option) {
    switch (option) {
      case SortOptions.alphabetical:
        category.sort((a, b) => ascending
            ? a.label.compareTo(b.label)
            : b.label.compareTo(a.label));
        break;
      case SortOptions.budget:
        category.sort((a, b) => ascending
            ? a.budget.compareTo(b.budget)
            : b.budget.compareTo(a.budget));
      case SortOptions.actualAmount:
        category.sort((a, b) => ascending
            ? a.actualAmount.compareTo(b.actualAmount)
            : b.actualAmount.compareTo(a.actualAmount));
      case SortOptions.position:
        category.sort((a, b) => ascending
            ? a.position.compareTo(b.position)
            : b.position.compareTo(a.position));
      case SortOptions.percentage:
        category.sort((a, b) => ascending
            ? a.budget == 0
              ? a.actualAmount == 0
                ? -1
                : b.budget == 0
                  ? a.actualAmount.compareTo(b.actualAmount)
                  : 1.compareTo(b.actualAmount / b.budget)
              : b.budget == 0
                ? b.actualAmount == 0
                  ? a.actualAmount == 0 ? -1 : 1
                  : (a.actualAmount / a.budget).compareTo(1)
                : (a.actualAmount / a.budget).compareTo(b.actualAmount / b.budget)
            : a.budget == 0
              ? a.actualAmount == 0
                ? 1
                : b.budget == 0
                  ? b.actualAmount.compareTo(a.actualAmount)
                  : -1.compareTo(b.actualAmount / b.budget)
              : b.budget == 0
                ? b.actualAmount == 0
                  ? a.actualAmount == 0 ? 1 : -1
                  : (1).compareTo(a.actualAmount / a.budget)
                : (b.actualAmount / b.budget).compareTo(a.actualAmount / a.budget));
    }
  }
}