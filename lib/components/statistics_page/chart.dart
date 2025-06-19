import 'package:flutter/material.dart';
import 'package:money_minder/components/categories_page/category_button.dart';
import 'package:money_minder/components/statistics_page/side_table/category_table.dart';
import 'package:money_minder/components/statistics_page/side_table/summary_table.dart';
import 'package:money_minder/components/statistics_page/statistics_helper.dart';

import '../../models/currency.dart';
import '../../models/date_filter.dart';
import '../../models/transaction.dart';
import '../../style/app_size.dart';
import 'charts/category_bar_chart.dart';
import 'charts/category_line_chart.dart';
import 'charts/category_stack_bar_chart.dart';

enum ChartType {
  categoryBarChart,
  categoryLineChart,
  categoryStackBarChart,
}

class Chart extends StatefulWidget {
  const Chart({
    super.key,
    required this.isExpense,
    required this.isExpanded,
    required this.shrinkChart,
    required this.chartType,
    required this.currency,
    required this.dateFilterType,
    required this.categories,
    this.transactions,
    this.startDate,
    this.endDate,
    this.showIndividual = false,
    this.onChangeType,
  });

  final bool isExpense;
  final bool isExpanded;
  final ChartType chartType;
  final Currency currency;
  final DateFilterType dateFilterType;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool showIndividual;
  final void Function()? onChangeType;
  final List<CategoryProp> categories;
  final List<Transaction>? transactions;
  final void Function()? shrinkChart;

  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart> {

  late List<Transaction> incomeTransactions;
  late List<Transaction> expenseTransactions;

  void load() {
    setState(() {
      incomeTransactions = widget.transactions!
          .where((transaction) => transaction.type == TransactionType.income).toList();
      expenseTransactions = widget.transactions!
          .where((transaction) => transaction.type == TransactionType.expense).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.transactions != null) load();
  }

  @override
  void didUpdateWidget(Chart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.transactions != null
        && widget.transactions != null
        && (oldWidget.transactions != widget.transactions
        || oldWidget.showIndividual != widget.showIndividual)) {
      load();
    }
  }

  @override
  Widget build(BuildContext context) {

    final bool isSmallScreen = MediaQuery.of(context).size.width <= 360;
    double height = widget.isExpanded
        ? MediaQuery.of(context).size.width * 0.8
        : isSmallScreen ? 145 : 200 - AppSize.smallPadding;
    double width = widget.isExpanded
        ? MediaQuery.of(context).size.height * 0.6
        : MediaQuery.of(context).size.width * 0.9;
    final aspectRatio = width / (height - 50);
    List<CategoryProp> bigCatList = StatisticsHelper.compressData(widget.categories, widget.isExpanded ? 12 : 6);
    List<CategoryProp> smallCatList = StatisticsHelper.compressData(widget.categories, widget.isExpanded ? 6 : 3);

    Widget child() {
      switch(widget.chartType) {
        case ChartType.categoryBarChart:
          return CategoryBarChart(
            aspectRatio: aspectRatio,
            isExpanded: widget.isExpanded,
            isExpense: widget.isExpense,
            currency: widget.currency,
            catList: bigCatList,
          );
        case ChartType.categoryLineChart:
          return CategoryLineChart(
            aspectRatio: aspectRatio,
            isExpanded: widget.isExpanded,
            isExpense: widget.isExpense,
            currency: widget.currency,
            startDate: widget.startDate!,
            endDate: widget.endDate!,
            type: widget.dateFilterType,
            showIndividual: widget.showIndividual,
            onChangeType: widget.onChangeType!,
            catList: smallCatList,
            transactions: widget.isExpense ? expenseTransactions : incomeTransactions,
          );
        case ChartType.categoryStackBarChart:
          return CategoryStackBarChart(
            aspectRatio: aspectRatio,
            isExpanded: widget.isExpanded,
            isExpense: widget.isExpense,
            currency: widget.currency,
            startDate: widget.startDate!,
            endDate: widget.endDate!,
            type: widget.dateFilterType,
            catList: smallCatList,
            transactions: widget.isExpense ? expenseTransactions : incomeTransactions,
          );
      }
    }

    return Stack(
      children: <Widget>[
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(AppSize.smallPadding),
                height: height,
                width: width,
                child: child(),
              ),
              !widget.isExpanded
                  ? SizedBox.shrink()
                  : Expanded(
                child: Container(
                  margin: EdgeInsets.all(AppSize.smallPadding),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(AppSize.borderRadius),
                  ),
                  child: !widget.showIndividual && widget.chartType == ChartType.categoryLineChart
                      ? SummaryTable(
                    startDate: widget.startDate!,
                    endDate: widget.endDate!,
                    totalAmount: StatisticsHelper.getTotalAmount(widget.transactions!
                        .where((transaction) => transaction.type ==
                        (widget.isExpense ? TransactionType.expense : TransactionType.income)).toList()),
                  )
                      : CategoryTable(catList: widget.chartType == ChartType.categoryBarChart ? bigCatList : smallCatList),
                ),
              ),
            ],
          ),
        ),

        widget.isExpanded
            ? Positioned(
          top: 5,
          right: 5,
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
              widget.shrinkChart!();
            },
            icon: const Icon(Icons.fullscreen_exit_outlined,
                size: 30
            ),
          ),
        )
            : SizedBox.shrink(),
      ],
    );
  }
}
