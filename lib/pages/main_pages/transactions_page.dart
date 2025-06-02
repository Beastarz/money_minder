import 'package:flutter/material.dart';
import 'package:money_minder/components/transaction/transaction_content.dart';
import 'package:money_minder/models/currency.dart';

import '../../components/calendar_bar/calendar_appbar.dart';
import '../../models/date_filter.dart';
import '../../models/transaction.dart';

/// page that shows the transactions
class TransactionsPage extends StatefulWidget {
  const TransactionsPage({
    super.key,
    required this.mainCurrency,
    required this.filteredTransactions,
    required this.dateFilter,
    required this.filteredAccountBalance,
    required this.onDateFilterUpdate,
    required this.currentPageIndex,
    required this.onPageChange, required this.onTransactionReload,
  });

  final double filteredAccountBalance;
  final Currency mainCurrency;
  final List<Transaction> filteredTransactions;
  final DateFilter dateFilter;
  final Function(DateFilter) onDateFilterUpdate;
  final int currentPageIndex;
  final void Function(int) onPageChange;
  final Function() onTransactionReload;

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> with TickerProviderStateMixin {
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

    List<double> accumulatedBalance = getAccumulatedBalance(groupedTransactions, widget.filteredAccountBalance);


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
        children: groupedTransactions.indexed.map((transactions) => TransactionsContent(
          transactions: transactions.$2,
          initialBalance: accumulatedBalance[transactions.$1],
          finalBalance: accumulatedBalance[transactions.$1 + 1],
          mainCurrency: widget.mainCurrency,
          onTransactionReload: widget.onTransactionReload,
        )).toList()
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


  List<double> getAccumulatedBalance(List<List<Transaction>> transactionsList, double initialBalance) {
    List<double> res = [initialBalance];
    for (int i = transactionsList.length - 1; i >= 0; i--) {
      double temp = res.last;
      for (Transaction t in transactionsList[i]) {
        if (t.type == TransactionType.expense){
          temp += t.mainAmount;
        } else if (t.type == TransactionType.income) {
          temp -= t.mainAmount;
        }
      }
      res.add(temp);
    }
    return res.reversed.toList();
  }

  void _onDateFilterChange(DateFilter dateFilter) async {
    widget.onDateFilterUpdate(dateFilter);
    setState(() {
      _pageViewController.jumpToPage(dateFilter.initialPageIndex);
      _tabController.index = dateFilter.initialPageIndex;
    });
  }
}