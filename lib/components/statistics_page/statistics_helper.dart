import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:money_minder/models/date_filter.dart';

import '../../models/transaction.dart';
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

  /// Helper method to compress some
  /// data that exceed the maximum length into 'other' category
  ///
  /// Parameters:
  ///
  /// List\<CategoryProp\> props: the list of categories
  ///
  /// int limitedLength: the maximum length of the list allowed
  ///
  /// return: List\<CategoryProp\>
  static List<CategoryProp> compressData(List<CategoryProp> props, int limitedLength) {

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
  static double getBarChartMaxY(List<CategoryProp> dataList) {
    double maxY = 0;
    for (CategoryProp data in dataList) {
      maxY = max(maxY, data.actualAmount);
    }
    return maxY;
  }

  /// Helper method to get the maximum y value of the line chart
  ///
  /// Parameters:
  ///
  /// List\<FlSpot\> dataList: the list of data points
  ///
  /// return: double
  static double getLineChartMaxY(List<FlSpot> dataList) {
    double maxY = 0;
    for (FlSpot data in dataList) {
      maxY = max(maxY, data.y);
    }
    return maxY;
  }

  /// Helper method to slice the period of the date range
  ///
  /// Parameters:
  ///
  /// DateTime startDate: the start date of the date range
  ///
  /// DateTime endDate: the end date of the date range
  ///
  /// bool isExpanded: whether the chart is expanded
  /// (period will be cut into more portion in expanded chart)
  ///
  /// DateFilterType type: the type of the date range
  ///
  /// return: List\<DateTime\>
  static List<DateTime> slicePeriod(
      DateTime startDate, DateTime endDate, bool isExpanded, DateFilterType type) {

    int range = endDate.difference(startDate).inDays + 1;
    List<DateTime> dates = [startDate];
    if (type == DateFilterType.year) {
      int year = startDate.year;
      if (isExpanded) {
        dates.add(DateTime(year, 4, 1));
        dates.add(DateTime(year, 7, 1));
        dates.add(DateTime(year, 10, 1));
      } else {
        dates.add(DateTime(year, 7, 1));
      }
    } else if (type == DateFilterType.week) {
      if (isExpanded) {
        for (int i = 1; i < 6; i++) {
          dates.add(startDate.add(Duration(days: i)));
        }
      } else {
        dates.add(startDate.add(Duration(days: 3)));
      }
    } else if (type == DateFilterType.month) {
      if (isExpanded) {
        for (int i = 1; i < 4; i++) {
          dates.add(startDate.add(Duration(days: i * 7)));
        }
      } else {
        dates.add(startDate.add(Duration(days: 14)));
      }
    } else if (range > 2) {
      int slice = (isExpanded && range >= 5) ? 4 : 2;
      int skip = range ~/ slice;
      for (int i = 1; i < slice; i++) {
        dates.add(startDate.add(Duration(days: skip * i)));
      }
    }
    dates.add(endDate);
    return dates;
  }

  /// Helper method to get the total amount of the transactions
  ///
  /// Parameters:
  ///
  /// List\<Transaction\> transactions: the list of transactions
  ///
  /// return: double
  static double getTotalAmount(List<Transaction> transactions) {
    double total = 0;
    for (Transaction transaction in transactions) {
      total += transaction.amount;
    }
    return total;
  }

  /// Helper method to add a spot recursively into the spots array
  ///
  /// Parameters:
  ///
  /// int index: the index of the dates array
  ///
  /// List\<DateTime\> dates: the list of dates
  ///
  /// DateTime date: the date of the transaction
  ///
  /// double amount: the amount of the transaction
  ///
  /// List\<FlSpot\> spots: the list of spots
  ///
  /// return: int (index of the dates array)
  static int addSpot(int index, List<DateTime> dates, DateTime date, double amount, List<FlSpot> spots) {
    if (date.isAtSameMomentAs(dates[index])) {
      spots.add(FlSpot(index.toDouble(), amount));
    } else if (date.isBefore(dates[index + 1])) {
      double x =  date.difference(dates[index]).inDays / (dates[index + 1].difference(dates[index]).inDays) + index;
      spots.add(FlSpot(x, amount));
    } else {
      return addSpot(index + 1, dates, date, amount, spots);
    }
    return index;
  }

  /// Helper method to get the data for the line chart
  ///
  /// Parameters:
  ///
  /// List\<Transaction\> transactions: the list of transactions
  ///
  /// List\<DateTime\> dates: the list of dates
  ///
  /// int days: the number of days to group the transactions
  ///
  /// return: List\<FlSpot\>
  static List<FlSpot> getLineChartData(List<Transaction> transactions, List<DateTime> dates, int days) {
    List<FlSpot> spots = [];
    int index = 0;
    List<DateTime> dateList = [];
    DateTime startDate = dates.first;
    DateTime endDate = dates.last;
    while (startDate.isBefore(endDate)) {
      dateList.add(startDate);
      startDate = startDate.add(Duration(days: days));
    }
    dateList.add(endDate);
    dateList.add(endDate.add(Duration(days: 1))); // to make sure last spot is collected
    List<List<Transaction>> groupedTransactions = Transaction.groupTransactionsByDate(transactions, dateList);
    startDate = dates.first;
    for (List<Transaction> group in groupedTransactions) {
      if (group.isEmpty) {
        index = addSpot(index, dates, startDate, 0, spots);
      } else {
        index = addSpot(index, dates, startDate, getTotalAmount(group), spots);
      }
      startDate = startDate.add(Duration(days: days));
      startDate = endDate.isBefore(startDate) ? endDate : startDate;
    }
    return spots;
  }

  /// Helper method to categorize the transactions
  ///
  /// Parameters:
  ///
  /// List\<Transaction\> transactions: the list of transactions
  ///
  /// List\<CategoryProp\> categories: the list of categories
  ///
  /// return: List\<List\<Transaction\>>
  static List<List<Transaction>> categorizeTransactions(List<Transaction> transactions, List<CategoryProp> categories) {
    List<List<Transaction>> t = [];
    for (CategoryProp _ in categories) {
      t.add([]);
    }
    for (Transaction transaction in transactions) {
      for (int i = 0; i < categories.length; i++) {
        if (transaction.toCategory!.id == categories[i].id) {
          t[i].add(transaction);
          break;
        }
      }
    }
    return t;
  }

  /// Helper method to get the data for the stack bar chart
  ///
  /// Parameters:
  ///
  /// List\<Transaction\> transactions: the list of transactions
  ///
  /// List\<DateTime\> dates: the list of dates
  ///
  /// int days: the number of days to group the transactions
  ///
  /// List\<CategoryProp\> catList: the list of categories
  ///
  /// return: List\<BarChartRodData\>
  static List<BarChartRodData> getStackBarChartDate(
      List<Transaction> transactions, List<DateTime> dates,
      int days, List<CategoryProp> catList, List<int> showDateIndex) {
    List<BarChartRodData> data = [];

    // slice the period
    List<DateTime> dateList = [];
    DateTime startDate = dates.first;
    DateTime endDate = dates.last;
    while (startDate.isBefore(endDate)) {
      dateList.add(startDate);
      startDate = startDate.add(Duration(days: days));
    }
    dateList.add(endDate);
    dateList.add(endDate.add(Duration(days: 1))); // to make sure last spot is collected
    List<List<Transaction>> groupedTransactions = Transaction.groupTransactionsByDate(transactions, dateList);
    startDate = dates.first;
    showDateIndex.clear();
    for (int i = 0; i < dates.length; i++) {
      showDateIndex.add(((groupedTransactions.length - 1) / (dates.length - 1) * i).round());
    }
    for (int i = 0; i < groupedTransactions.length; i++) {
      List<Transaction> group = groupedTransactions[i];
      List<List<Transaction>> categorizedTransactions = categorizeTransactions(group, catList);
      double fromY = 0;
      double toY = 0;
      List<BarChartRodStackItem> rods = [];
      for (int i = 0; i < categorizedTransactions.length; i++) {
        toY += getTotalAmount(categorizedTransactions[i]);
        rods.add(BarChartRodStackItem(fromY, toY, catList[i].color));
        fromY = toY;
      }
      data.add(
        BarChartRodData(
          toY: toY,
          rodStackItems: rods,
          borderRadius: BorderRadius.zero,
        ),
      );
    }
    return data;
  }
}