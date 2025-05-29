import 'package:flutter/material.dart';
import 'package:money_minder/components/categories_page/categories_page_content.dart';

import '../../components/calendar_bar/calendar_appbar.dart';
import '../../models/date_filter.dart';
import '../../models/transaction.dart';
import '../../repositories/date_filter_repositories.dart';
import '../../repositories/transactions_repositories.dart';

/// the page that shows the categories
class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key, required this.filteredTransactions, required this.dateFilter, required this.onDateFilterUpdate, required this.currentPageIndex, required this.onPageChange});

  final List<Transaction> filteredTransactions;
  final DateFilter dateFilter;
  final Function(DateFilter) onDateFilterUpdate;
  final int currentPageIndex;
  final void Function(int) onPageChange;

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

    /// map this to categories and transactions page
    List<List<Transaction>> groupedTransactions = Transaction.groupTransactionsByDate(widget.filteredTransactions, widget.dateFilter.startDates);

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
            //children: groupedTransactions.map((e) => Center(child: Text(e.join('\n')))).toList()
            children: [CategoriesPageContent()],
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

