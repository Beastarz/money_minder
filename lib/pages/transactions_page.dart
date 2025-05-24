import 'package:flutter/material.dart';
import 'package:money_minder/repositories/transactions_repositories.dart';

import '../components/calendar_bar/calendar_appbar.dart';
import '../models/date_filter.dart';
import '../models/transaction.dart';
import '../repositories/date_filter_repositories.dart';

/// page that shows the transactions
class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> with TickerProviderStateMixin {
  late PageController _pageViewController;
  late TabController _tabController;
  late int _currentPageIndex;
  List<Transaction> transactions = [];
  DateFilter dateFilter = DateFilter.fromType(DateFilterType.month);
  bool isTappable = true;

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
    () async {
      List<Transaction> res = await TransactionsRepositories().getTransactions();
      setState(() {
        transactions = res;
      });
    }();
  }

  Future<void> fetchDateFilter() async {
    var res = await DateFilterRepositories().getDateFilter();
    print(res.type);
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

    /// map this to categories and transactions page
    List<List<Transaction>> groupedTransactions = Transaction.groupTransactionsByDate(transactions, dateFilter.startDates);

    // for (var element in groupedTransactions) {
    //   print(element.map((e) => e.toString()).toList());
    // }

    return Scaffold(
      appBar: CalendarAppBar(
        tabController: _tabController,
        currentPageIndex: _currentPageIndex,
        onUpdateCurrentPageIndex: _updateCurrentPageIndex,
        dateString: dateFilter.convertString(_currentPageIndex),
        maxIndex: dateFilter.startDates.length - 2,
        dateFilterType: dateFilter.type,
        isTappable: isTappable,
        onUpdateDateFilter: _updateDateFilter,
      ),
      body: !isTappable ? Center(child: Text(groupedTransactions[0].join('\n')),) :
      PageView(
        controller: _pageViewController,
        onPageChanged: _handlePageViewChanged,
        children: groupedTransactions.map((e) => Center(child: Text(e.join('\n')))).toList()
      )
    );
  }

  void _handlePageViewChanged(int currentPageIndex) {
    print(currentPageIndex);
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
      print(_currentPageIndex);
      _pageViewController.jumpToPage(_currentPageIndex);
      _tabController.index = _currentPageIndex;
    });
  }
}