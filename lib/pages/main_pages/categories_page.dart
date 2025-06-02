import 'package:flutter/material.dart';
import 'package:money_minder/components/categories_page/categories_page_content.dart';
import 'package:money_minder/components/categories_page/category_helper.dart';
import 'package:money_minder/models/currency.dart';

import '../../components/calendar_bar/calendar_appbar.dart';
import '../../components/categories_page/category_button.dart';
import '../../models/budget.dart';
import '../../models/category.dart';
import '../../models/date_filter.dart';
import '../../models/transaction.dart';

/// the page that shows the categories
class CategoriesPage extends StatefulWidget {

  final List<List<Category>> categories;
  final List<Transaction> filteredTransactions;
  final List<Budget> budgets;
  final Currency mainCurrency;
  final DateFilter dateFilter;
  final Function(DateFilter) onDateFilterUpdate;
  final int currentPageIndex;
  final void Function(int) onPageChange;
  final void Function() onAddTransactionReload;

  const CategoriesPage({
    super.key,
    required this.filteredTransactions,
    required this.dateFilter,
    required this.mainCurrency,
    required this.onDateFilterUpdate,
    required this.currentPageIndex,
    required this.onPageChange,
    required this.categories,
    required this.budgets,
    required this.onAddTransactionReload,
  });


  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> with TickerProviderStateMixin {

  late PageController _pageViewController;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _pageViewController = PageController(initialPage: widget.currentPageIndex);
    _tabController = TabController(
        length: widget.dateFilter.startDates.length - 1,
        initialIndex: 50,
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
        body:  PageView(
        controller: _pageViewController,
        onPageChanged: _handlePageViewChanged,
        children: groupedTransactions.indexed.map((t) {
          int index = t.$1;
          List<Transaction> transactions = t.$2;
          List<double> totalAmounts = [0, 0];
          List<Budget> budgets = CategoryHelper.getBudgets(groupedBudgets[index]);
          List<CategoryProp> expenseCats =
            CategoryHelper.convertToCatButProps(
              widget.categories[0], transactions, budgets,
              totalAmounts, true, widget.dateFilter);
          List<CategoryProp> incomeCats =
            CategoryHelper.convertToCatButProps(
              widget.categories[1], transactions, budgets,
              totalAmounts, false, widget.dateFilter);
          expenseCats.add(AddCategoryProp(expenseCats.length));
          incomeCats.add(AddCategoryProp(incomeCats.length));
          return CategoriesPageContent(
            categories: [expenseCats, incomeCats],
            totalAmounts: totalAmounts,
            mainCurrency: widget.mainCurrency,
            onAddTransactionReload: widget.onAddTransactionReload,
          );
          }
        ).toList()
      )
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

