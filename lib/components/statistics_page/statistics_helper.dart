import 'dart:math';

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
      List<CategoryProp> category, bool ascending, SortOptions option, double totalAmount) {
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
            ? totalAmount == 0
              ? a.position.compareTo(b.position)
              : (a.actualAmount / totalAmount).compareTo(b.actualAmount / totalAmount)
            : totalAmount == 0
              ? b.position.compareTo(a.position)
              : (b.actualAmount / totalAmount).compareTo(a.actualAmount / totalAmount));
    }
  }

  /// Helper method to normalize the percentage of actual amount of each category over total amount
  ///
  /// Parameters:
  ///
  /// List\<CategoryProp\> category: the list of categories
  ///
  /// double totalAmount: the total amount of the categories
  ///
  /// return: List\<double\>
  static List<double> calculatePercentages(List<CategoryProp> category, double totalAmount) {
    double highestPercentage = 0;
    List<double> percentages = [];
    for (CategoryProp cat in category) {
      percentages.add(totalAmount == 0 ? 0 : cat.actualAmount / totalAmount);
      highestPercentage = max(highestPercentage, percentages.last);
    }
    if (highestPercentage == 0) {
      return percentages;
    }
    for (int i = 0; i < percentages.length; i++) {
      percentages[i] = percentages[i] / highestPercentage;
    }
    return percentages;
  }

  /// Helper method to clean the data of the category list, compressed some
  /// data that exceed the maximum length into 'other' category
  ///
  /// Parameters:
  ///
  /// List\<CategoryProp\> props: the list of categories
  ///
  /// int limitedLength: the maximum length of the list allowed
  ///
  /// return: List\<CategoryProp\>
  static List<CategoryProp> cleanData(List<CategoryProp> props, int limitedLength) {

    // testing
    // props = List.from(props);
    //
    // for (int i = 0; i < 20; i++) {
    //   props.add(CategoryProp(
    //       id: 0,
    //       position: 10,
    //       label: "testing",
    //       icon: Icon(Icons.access_time_sharp),
    //       color: Colors.blueGrey,
    //       actualAmount: 10,
    //       budget: 0,
    //       isExpense: true));
    // }

    int length = props.length;

    if (length <= limitedLength) {
      return List.from(props);
    }
    List<CategoryProp> newList = props.sublist(0, limitedLength - 1);
    double totalAmount = 0;
    for (int i = limitedLength; i < length; i++) {
      totalAmount += props[i].actualAmount;
    }
    newList.add(CategoryProp(
        id: -1, // does not matter
        position: limitedLength,
        label: "Others",
        icon: Icon(
          Icons.more_horiz,
          color: Colors.grey,
        ),
        color: Colors.grey,
        actualAmount: totalAmount,
        budget: 0, // does not matter
        isExpense: true // does not matter
    ));
    return newList;
  }

  /// Helper method to get the maximum y value of the bar chart
  ///
  /// Parameters:
  ///
  /// List\<CategoryProp\> dataList: the list of categories
  ///
  /// return: double
  static double getMaxY(List<CategoryProp> dataList) {
    double maxY = 0;
    for (CategoryProp data in dataList) {
      maxY = max(maxY, data.actualAmount);
    }
    return maxY;
  }
}