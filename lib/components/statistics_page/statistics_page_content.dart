import 'package:flutter/material.dart';
import 'package:money_minder/components/statistics_page/statistic_sheet.dart';

import '../../models/currency.dart';
import '../../style/app_size.dart';
import '../budget_page/budget_tile.dart';
import '../categories_page/category_button.dart';

class StatisticsPageContent extends StatefulWidget {

  final List<List<CategoryProp>> categories;
  final List<double> totalAmounts;
  final List<double> totalBudgets;
  final Currency mainCurrency;
  final bool disabledAddBudget;
  final DateTime startDate;
  final void Function() onAddTransactionReload;
  final void Function() onBudgetReload;

  const StatisticsPageContent({
    super.key,
    required this.categories,
    required this.totalAmounts,
    required this.totalBudgets,
    required this.mainCurrency,
    required this.disabledAddBudget,
    required this.startDate,
    required this.onAddTransactionReload,
    required this.onBudgetReload,
  });

  @override
  State<StatisticsPageContent> createState() => _StatisticsPageContentState();
}

class _StatisticsPageContentState extends State<StatisticsPageContent> {

  bool _isExpense = true;

  // switch between expense sheet and income sheet
  void switchContent(bool isExpense) {
    setState(() {
      _isExpense = isExpense;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSize.smallPadding),
      child: Column(
        children: [
          BudgetTile(
            prop: CategoryProp(
              id: -1,
              position: -1,
              label: _isExpense ? 'Expense' : 'Income',
              icon: _isExpense ? Icon(Icons.money_off) : Icon(Icons.attach_money),
              color: _isExpense ? Colors.redAccent : Colors.green,
              budget: widget.totalBudgets[_isExpense ? 0 : 1],
              actualAmount: widget.totalAmounts[_isExpense ? 0 : 1],
              isExpense: _isExpense,
            ),
            mainCurrency: widget.mainCurrency,
            isCurve: true,
            onPressed: () {
              setState(() {
                _isExpense = !_isExpense;
              });
            }
          ),
          SizedBox(height: AppSize.smallPadding),
          Expanded(
            child: StatisticsSheet(
              isExpense: _isExpense,
              categories: widget.categories,
              mainCurrency: widget.mainCurrency,
              startDate: widget.startDate,
              disabledAddBudget: widget.disabledAddBudget,
              onAddTransactionReload: widget.onAddTransactionReload,
              onBudgetReload: widget.onBudgetReload,
              totalAmounts: widget.totalAmounts,
            )
          ),
        ]
      ),
    );
  }
}
