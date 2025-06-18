import 'package:flutter/material.dart';
import 'package:money_minder/components/statistics_page/statistics_page_content.dart';
import 'package:money_minder/models/currency.dart';

import '../../components/calendar_bar/calendar_appbar.dart';
import '../../components/categories_page/category_button.dart';
import '../../components/categories_page/category_helper.dart';
import '../../models/budget.dart';
import '../../models/category.dart';
import '../../models/date_filter.dart';
import '../../models/transaction.dart';

/// page that shows the transactions
class StatisticsPage extends StatefulWidget {
  const StatisticsPage({
    super.key,
    required this.mainCurrency,
    required this.groupedTransactions,
    required this.groupedBudgets,
    required this.categories,
    required this.dateFilter,
    required this.onDateFilterUpdate,
    required this.currentPageIndex,
    required this.onPageChange,
    required this.onTransactionReload,
    required this.onBudgetReload,
    required this.showCategoryTransactions,
  });

  final Currency mainCurrency;
  final List<List<Transaction>> groupedTransactions;
  final List<List<Budget>> groupedBudgets;
  final List<List<Category>> categories;
  final DateFilter dateFilter;
  final Function(DateFilter) onDateFilterUpdate;
  final int currentPageIndex;
  final void Function(int) onPageChange;
  final void Function(int) showCategoryTransactions;
  final void Function() onTransactionReload;
  final void Function() onBudgetReload;

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> with TickerProviderStateMixin {
  late PageController _pageViewController;
  late TabController _tabController;
  late List<Widget> _pages;

  void _handlePageViewChanged(int currentPageIndex) {
    _tabController.index = currentPageIndex;
    widget.onPageChange(currentPageIndex);
  }

  void _updateCurrentPageIndex(int index) {
    _tabController.index = index;
    _pageViewController.jumpToPage(index);
    widget.onPageChange(index);
  }

  void _onDateFilterChange(DateFilter dateFilter) async {
    widget.onDateFilterUpdate(dateFilter);
    setState(() {
      _pageViewController.jumpToPage(dateFilter.initialPageIndex);
      _tabController.index = dateFilter.initialPageIndex;
    });
  }

  DateTime _getEndDate(int index) {
    DateTime startDate = widget.dateFilter.startDates[index];
    int year = startDate.year;
    int month = startDate.month;
    int day = startDate.day;

    if (widget.dateFilter.type case DateFilterType.all) {
      return DateTime.now();
    } else if (widget.dateFilter.type case DateFilterType.year) {
      return DateTime(year + 1, month, day).subtract(Duration(days: 1));
    } else if (widget.dateFilter.type case DateFilterType.month) {
      if (month == 12) {
        month = 1;
        year += 1;
      }  else {
        month += 1;
      }
      return DateTime(year, month, day).subtract(Duration(days: 1));
    } else if (widget.dateFilter.type case DateFilterType.week) {
      return DateTime(year, month, day).add(Duration(days: 6));
    } else if (widget.dateFilter.type case DateFilterType.day) {
      return startDate;
    } else if (widget.dateFilter.type case DateFilterType.range) {
      int range = widget.dateFilter.startDates[1].difference(widget.dateFilter.startDates[0]).inDays;
      return DateTime(year, month, day).add(Duration(days: range - 1));
    }
    return DateTime.now();
  }

  void getPages() {
    final bool disabledAddBudget = widget.dateFilter.type != DateFilterType.month;
    setState(() {
      _pages = widget.groupedTransactions.indexed.map((t) {
        int index = t.$1;
        List<Transaction> transactions = t.$2;
        List<double> totalAmounts = [0, 0];
        List<Budget> budgets = widget.groupedBudgets[index];
        List<CategoryProp> expenseCats =
        CategoryHelper.convertToCatButProps(
            widget.categories[0], transactions, budgets,
            totalAmounts, true, widget.dateFilter);
        List<CategoryProp> incomeCats =
        CategoryHelper.convertToCatButProps(
            widget.categories[1], transactions, budgets,
            totalAmounts, false, widget.dateFilter);
        List<double> totalBudgets = [
          CategoryHelper.getTotalBudget(budgets, true),
          CategoryHelper.getTotalBudget(budgets, false),
        ];
        DateTime startDate = widget.dateFilter.type == DateFilterType.all
          ? DateTime(2025, 1, 1) // TODO: make it be the first day user using the app
          : widget.dateFilter.startDates[index];
        return StatisticsPageContent(
          categories: [expenseCats, incomeCats],
          totalAmounts: totalAmounts,
          totalBudgets: totalBudgets,
          mainCurrency: widget.mainCurrency,
          disabledAddBudget: disabledAddBudget,
          dateFilterType: widget.dateFilter.type,
          transactions: transactions,
          startDate: startDate,
          endDate: _getEndDate(index),
          showCategoryTransactions: widget.showCategoryTransactions,
          onTransactionReload: widget.onTransactionReload,
          onBudgetReload: widget.onBudgetReload,
          defaultDateForTransaction: index == 50
              ? DateTime.now()
              : index > 50
              ? widget.dateFilter.startDates[index]
              : widget.dateFilter.startDates[index + 1].subtract(Duration(days: 1)),
        );
      }
      ).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _pageViewController = PageController(initialPage: widget.currentPageIndex);
    _tabController = TabController(
        length: 100,
        initialIndex: widget.currentPageIndex,
        vsync: this
    );
    getPages();
  }

  @override
  void didUpdateWidget(covariant StatisticsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.groupedTransactions != oldWidget.groupedTransactions ||
    widget.groupedBudgets != oldWidget.groupedBudgets) {
      getPages();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: CalendarAppBar(
        tabController: _tabController,
        currentPageIndex: widget.currentPageIndex,
        onUpdateCurrentPageIndex: _updateCurrentPageIndex,
        dateString: widget.dateFilter.convertString(widget.currentPageIndex),
        maxIndex: widget.dateFilter.startDates.length - 2,
        dateFilterType: widget.dateFilter.type,
        onUpdateDateFilter: _onDateFilterChange,
      ),
      body: PageView(
          controller: _pageViewController,
          onPageChanged: _handlePageViewChanged,
          physics: widget.dateFilter.type == DateFilterType.all ? NeverScrollableScrollPhysics() : ScrollPhysics(),
          children: _pages
      ),
    );
  }
}