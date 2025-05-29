import 'package:flutter/material.dart';
import 'package:money_minder/components/categories_page/categories_page_content.dart';
import 'package:money_minder/components/categories_page/categories_page_helper.dart';

import '../../components/calendar_bar/calendar_appbar.dart';
import '../../components/categories_page/categories_button.dart';
import '../../models/category.dart';
import '../../models/date_filter.dart';
import '../../models/transaction.dart';
import '../../repositories/date_filter_repositories.dart';
import '../../repositories/transactions_repositories.dart';

/// the page that shows the categories
class CategoriesPage extends StatefulWidget {

  final List<List<Category>> categories;

  const CategoriesPage({
    super.key,
    required this.categories,
  });

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> with TickerProviderStateMixin {

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
      List<Transaction> res = await TransactionsRepositories.instance.getTransactions();
      setState(() {
        transactions = res;
      });
    }();
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

    /// map this to categories and transactions page
    List<List<Transaction>> groupedTransactions = Transaction.groupTransactionsByDate(transactions, dateFilter.startDates);

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
        children: groupedTransactions.map((transaction) {
          List<double> totalAmounts = [0, 0];
          List<CategoryButtonProps> expenseCats =
            CategoriesPageHelper.convertToCatButProps(
              widget.categories[0], transaction, totalAmounts, true);
          List<CategoryButtonProps> incomeCats =
            CategoriesPageHelper.convertToCatButProps(
              widget.categories[1], transaction, totalAmounts, false);
          expenseCats.add(AddCategoriesButtonProps(expenseCats.length));
          incomeCats.add(AddCategoriesButtonProps(incomeCats.length));
          return CategoriesPageContent(
            categories: [expenseCats, incomeCats],
            totalAmounts: totalAmounts,
          );
          // return Text(transaction.join('\n'));
          }
        ).toList()
      )
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

