import 'package:flutter/material.dart';
import 'package:money_minder/components/budget_page/budget_page_content.dart';

import  '../../components/calendar_bar/calendar_appbar.dart';
import '../../models/date_filter.dart';
import '../../repositories/date_filter_repositories.dart';

/// the page that shows the budget
class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> with TickerProviderStateMixin {
  late PageController _pageViewController;
  late TabController _tabController;
  late int _currentPageIndex;
  DateFilter dateFilter = DateFilter.fromType(DateFilterType.month);

  @override
  void initState() {
    super.initState();
    _currentPageIndex = dateFilter.initialPageIndex;
    _pageViewController = PageController(initialPage: _currentPageIndex);
    _tabController = TabController(
        length: dateFilter.startDates.length - 1,
        initialIndex: _currentPageIndex,
        vsync: this
    );
    fetchDateFilter();
  }

  Future<void> fetchDateFilter() async {
    var res = await DateFilterRepositories().getDateFilter();
    setState(() {
      dateFilter = res;
      _currentPageIndex = dateFilter.initialPageIndex;
      _pageViewController.jumpToPage(_currentPageIndex);
      _tabController.index = _currentPageIndex;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _pageViewController.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // List<Transaction> transactionsByAccount = widget.transactions.where((t) => widget.filteredAccountIds.contains(t.fromAccount.id)
    //     || widget.filteredAccountIds.contains(t.toAccount?.id)).toList();

    /// map this to categories and transactions page
    // List<List<Transaction>> groupedTransactions = Transaction.groupTransactionsByDate(transactionsByAccount, dateFilter.startDates);

    // List<double> accumulatedBalance = getAccumulatedBalance(groupedTransactions, widget.filteredAccountBalance);

    return Scaffold(
      appBar: CalendarAppBar(
        tabController: _tabController,
        currentPageIndex: _currentPageIndex,
        onUpdateCurrentPageIndex: _updateCurrentPageIndex,
        dateString: dateFilter.convertString(_currentPageIndex),
        maxIndex: dateFilter.startDates.length - 2,
        dateFilterType: dateFilter.type,
        onUpdateDateFilter: _updateDateFilter,
      ),
      body: PageView(
        controller: _pageViewController,
        onPageChanged: _handlePageViewChanged,
        // children: groupedTransactions.indexed.map((transactions) => TransactionsContent(
        //   transactions: transactions.$2,
        //   initialBalance: accumulatedBalance[transactions.$1],
        //   finalBalance: accumulatedBalance[transactions.$1 + 1],
        //   mainCurrency: widget.mainCurrency,
        // )).toList()
        children: [BudgetPageContent()],
      ),
    );
  }

  void _handlePageViewChanged(int currentPageIndex) {
    _tabController.index = currentPageIndex;
    setState(() {
      _currentPageIndex = currentPageIndex;
    });
  }

  void _updateCurrentPageIndex(int index) {
    _tabController.index = index;
    _pageViewController.jumpToPage(index);
    setState(() {
      _currentPageIndex = index;
    });
  }

  void _updateDateFilter(DateFilter dateFilter) {
    setState(() {
      this.dateFilter = dateFilter;
      _currentPageIndex = dateFilter.initialPageIndex;
      _pageViewController.jumpToPage(_currentPageIndex);
      _tabController.index = _currentPageIndex;
    });
  }
}

