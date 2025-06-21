import 'package:draggable_home/draggable_home.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:money_minder/components/categories_page/category_button.dart';
import 'package:money_minder/components/categories_page/center_button.dart';
import 'package:money_minder/components/categories_page/center_pie_chart.dart';

import '../../models/currency.dart';
import 'categories_sheet.dart';
import 'category_helper.dart';

class CategoriesPageContent extends StatefulWidget {

  /// constructor
  final List<List<CategoryProp>> categories;
  final List<double> totalAmounts;
  final Currency mainCurrency;
  final bool disabledAddBudget;
  final DateTime startDate;
  final DateTime defaultDateForTransaction;
  final Function(int) showCategoryTransactions;
  final Future<void> Function() onTransactionReload;
  final Future<void> Function() onBudgetReload;
  final Future<void> Function() onCategoryReload;

  const CategoriesPageContent({
    super.key,
    required this.categories,
    required this.totalAmounts,
    required this.mainCurrency,
    required this.disabledAddBudget,
    required this.startDate,
    required this.onTransactionReload,
    required this.onBudgetReload,
    required this.onCategoryReload,
    required this.defaultDateForTransaction,
    required this.showCategoryTransactions,
  });

  @override
  State<CategoriesPageContent>createState() => _CategoriesPageContentState();
}

class _CategoriesPageContentState extends State<CategoriesPageContent> {

  /// variables
  // track if currently showing expense or income
  bool _isExpense = true;
  // track which category is chosen
  int _pieTouchedIndex = -1;

  @override
  void initState() {
    super.initState();
  }

  // the center button will toggle between showing expenses and income each
  // time it is clicked.
  void centerButtonOnPressed() {
    setState(() {
      _isExpense = !_isExpense;
      _pieTouchedIndex = -1;
    });
  }

  // when the categories button is pressed, set _pieTouchedIndex to -1,
  // calculator will be shown to enter new transaction
  void categoriesButtonOnPressed(CategoryProp prop) {
    setState(() {
      _pieTouchedIndex = -1;
    });

    CategoryHelper.showCategoryCard(
      context,
      prop,
      widget.mainCurrency,
      widget.startDate,
      widget.defaultDateForTransaction,
      widget.disabledAddBudget,
      widget.onTransactionReload,
      widget.onBudgetReload,
      widget.showCategoryTransactions,
      props: widget.categories[_isExpense ? 0 : 1],
      reloadCategory: widget.onCategoryReload,
      disabledEditCategory: false,
    );
  }

  // when the pie data is touched for the first time, set _pieTouchedIndex to
  // corresponding index, set it to -1, which is the default value on the second
  // time.
  // when the pie data is set, respective categories button's animation will be
  // triggered. Pie chart will also show the corresponding percentage.
  void pieDataIsTouched(FlTouchEvent e , PieTouchResponse? r) {
    if (r != null && r.touchedSection != null) {
      setState(() {
        if (_pieTouchedIndex == r.touchedSection!.touchedSectionIndex) {
          _pieTouchedIndex = -1;
          return;
        }
        _pieTouchedIndex = r.touchedSection!.touchedSectionIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    final List<CategoryProp> categories =
      widget.categories[_isExpense ? 0 : 1];

    return DraggableHome(
      title: Text("Categories"),
      headerWidget: Stack(
        alignment: Alignment.center,
        children: [
          CenterPieChart(
            isExpense: _isExpense,
            pieTouchedIndex: _pieTouchedIndex,
            touchCallback: pieDataIsTouched,
            list: categories,
            totalAmount: widget.totalAmounts[_isExpense ? 0 : 1],
          ),
          CenterButton(
            centerButtonOnPressed: centerButtonOnPressed,
            isExpense: _isExpense,
            totalExpense: widget.totalAmounts[0],
            totalIncome: widget.totalAmounts[1],
            mainCurrency: widget.mainCurrency,
          )
        ],
      ),
      headerExpandedHeight: 0.40,
      body: [
        CategoriesSheet(
          isExpense: _isExpense,
          pieTouchedIndex: _pieTouchedIndex,
          categoriesButtonOnPressed: categoriesButtonOnPressed,
          categories: categories,
          mainCurrency: widget.mainCurrency,
          onCategoryReload: widget.onCategoryReload,
          onTransactionReload: widget.onTransactionReload,
          onBudgetReload: widget.onBudgetReload,
          resetPieIndex: () {
            setState(() {
              _pieTouchedIndex = -1;
            });
          }
      )]
    );
  }
}
