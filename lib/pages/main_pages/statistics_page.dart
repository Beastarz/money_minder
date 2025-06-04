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
    required this.filteredTransactions,
    required this.budgets,
    required this.categories,
    required this.dateFilter,
    required this.onDateFilterUpdate,
    required this.currentPageIndex,
    required this.onPageChange,
  });

  final Currency mainCurrency;
  final List<Transaction> filteredTransactions;
  final List<Budget> budgets;
  final List<List<Category>> categories;
  final DateFilter dateFilter;
  final Function(DateFilter) onDateFilterUpdate;
  final int currentPageIndex;
  final void Function(int) onPageChange;

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> with TickerProviderStateMixin {
  late PageController _pageViewController;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _pageViewController = PageController(initialPage: widget.currentPageIndex);
    _tabController = TabController(
        length: 100,
        initialIndex: widget.currentPageIndex,
        vsync: this
    );
  }

  @override
  Widget build(BuildContext context) {

    /// group transactions by period
    List<List<Transaction>> groupedTransactions = Transaction.groupTransactionsByDate(
        widget.filteredTransactions, widget.dateFilter.startDates);

    /// group budgets by period
    List<List<Budget>> groupedBudgets = Budget.groupBudgetsByDate(
        widget.budgets, widget.dateFilter);


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
          children: groupedTransactions.indexed.map((t) {
            int index = t.$1;
            List<Transaction> transactions = t.$2;
            List<double> totalAmounts = [0, 0];
            List<Budget> budgets = groupedBudgets[index];
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
            return StatisticsPageContent(
              categories: [expenseCats, incomeCats],
              totalAmounts: totalAmounts,
              totalBudgets: totalBudgets,
              mainCurrency: widget.mainCurrency,
            );
          }
          ).toList()
      ),
    );
  }

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
}