import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/calendar_bar/calendar_appbar.dart';
import '../models/date_filter.dart';
import '../providers/date_filter_provider.dart';

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

  @override
  void initState() {
    super.initState();
    DateFilter dateFilter = context.read<DateFilterProvider>().dateFilter;
    _currentPageIndex = dateFilter.initialPageIndex;
    _pageViewController = PageController(initialPage: _currentPageIndex, keepPage: false);
    _tabController = TabController(
        length: dateFilter.dates.length - 2,
        initialIndex: _currentPageIndex,
        vsync: this
    );
  }

  @override
  void dispose() {
    super.dispose();
    _pageViewController.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DateFilter dateFilter = context.watch<DateFilterProvider>().dateFilter;
    _currentPageIndex = context.watch<DateFilterProvider>().initialPageIndex;
    List<DateTime> startDates = dateFilter.dates;
    String dateString = dateFilter.convertString(_currentPageIndex);

    for(var date in startDates) {
      print(date);
    }

    return Scaffold(
      appBar: CalendarAppBar(
        tabController: _tabController,
        currentPageIndex: _currentPageIndex,
        onUpdateCurrentPageIndex: _updateCurrentPageIndex,
        dateString: dateString,
        maxIndex: startDates.length - 2,
        dateFilterType: dateFilter.type,
      ),
      body: PageView(
        controller: _pageViewController,
        onPageChanged: _handlePageViewChanged,
        children: startDates.map((e) => Center(child: Text(dateString))).toList()
      )
    );
  }

  void _handlePageViewChanged(int currentPageIndex) {
    _tabController.index = currentPageIndex;
    context.read<DateFilterProvider>().setPageIndex(currentPageIndex);
  }

  void _updateCurrentPageIndex(int index) {
    _tabController.index = index;
    _pageViewController.jumpToPage(index);
  }
}