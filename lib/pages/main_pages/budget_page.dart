import 'package:flutter/material.dart';
import 'package:money_minder/models/currency.dart';

import '../../components/budget_page/budget_page_content.dart';
import '../../components/calendar_bar/calendar_appbar.dart';
import '../../components/categories_page/categories_button.dart';
import '../../components/categories_page/categories_page_helper.dart';
import '../../models/category.dart';
import '../../models/date_filter.dart';
import '../../models/transaction.dart';

/// page that shows the transactions
class BudgetPage extends StatefulWidget {
  const BudgetPage({
    super.key,
    required this.mainCurrency,
    required this.filteredTransactions,
    required this.dateFilter,
    required this.filteredAccountBalance,
    required this.onDateFilterUpdate,
    required this.currentPageIndex,
    required this.onPageChange,
    required this.categories,
  });

  final double filteredAccountBalance;
  final Currency mainCurrency;
  final List<Transaction> filteredTransactions;
  final DateFilter dateFilter;
  final Function(DateFilter) onDateFilterUpdate;
  final int currentPageIndex;
  final void Function(int) onPageChange;
  final List<List<Category>> categories;

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> with TickerProviderStateMixin {
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

    /// map this to categories and transactions page
    List<List<Transaction>> groupedTransactions = Transaction.groupTransactionsByDate(
        widget.filteredTransactions, widget.dateFilter.startDates);


    return Scaffold(
      appBar: CalendarAppBar(
        tabController: _tabController,
        currentPageIndex: widget.currentPageIndex,
        onUpdateCurrentPageIndex: _updateCurrentPageIndex,
        dateString: widget.dateFilter.convertString(widget.currentPageIndex),
        maxIndex: widget.dateFilter.startDates.length - 2,
        dateFilterType: widget.dateFilter.type,
        onUpdateDateFilter: _onDateFilterChange,
        disabled: true,
      ),
      body: PageView(
          controller: _pageViewController,
          onPageChanged: _handlePageViewChanged,
          physics: widget.dateFilter.type == DateFilterType.all ? NeverScrollableScrollPhysics() : ScrollPhysics(),
          children: groupedTransactions.map((transactions) {
            List<double> totalAmounts = [0, 0];
            List<CategoryButtonProps> expenseCats =
            CategoriesPageHelper.convertToCatButProps(
                widget.categories[0], transactions, totalAmounts, true, widget.dateFilter);
            List<CategoryButtonProps> incomeCats =
            CategoriesPageHelper.convertToCatButProps(
                widget.categories[1], transactions, totalAmounts, false, widget.dateFilter);
            totalAmounts.insert(1, 0); // TODO: Fetch transactions
            return BudgetPageContent(
              expenseCats: expenseCats,
              incomeCats: incomeCats,
              totalAmounts: totalAmounts,
              mainCurrency: widget.mainCurrency,
            );
          }).toList()
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