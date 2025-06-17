import 'package:flutter/material.dart';
import 'package:money_minder/components/categories_page/category_button.dart';

import '../../models/currency.dart';
import '../../models/date_filter.dart';
import '../../models/transaction.dart';
import '../../style/app_size.dart';
import 'chart.dart';

class ChartPages extends StatefulWidget {
  const ChartPages({
    super.key,
    required this.isExpanded,
    required this.isExpense,
    this.shrinkChart,
    required this.categories,
    required this.currency,
    required this.transactions,
    required this.dateFilterType,
    required this.startDate,
    required this.endDate,
    required this.currentPage,
    required this.updateCurrentPage,
  });

  final bool isExpanded;
  final bool isExpense;
  final void Function()? shrinkChart;
  final List<CategoryProp> categories;
  final List<Transaction> transactions;
  final Currency currency;
  final DateFilterType dateFilterType;
  final DateTime startDate;
  final DateTime endDate;
  final int currentPage;
  final void Function(int) updateCurrentPage;

  @override
  State<ChartPages> createState() => _ChartPagesState();
}

class _ChartPagesState extends State<ChartPages> with TickerProviderStateMixin {

  late PageController _pageViewController;
  late TabController _tabController;
  late int totalPages;

  void _handlePageViewChanged(int index) {
    _tabController.index = index % totalPages;
    _pageViewController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    widget.updateCurrentPage(index);
  }

  void load() {
    totalPages = widget.endDate.difference(widget.startDate).inDays == 0 ? 1 : 3;
    _pageViewController = PageController(initialPage: widget.currentPage == 0
        ? totalPages * 1000
        : widget.currentPage);
    _tabController = TabController(length: totalPages, vsync: this);
    _tabController.index = widget.currentPage % totalPages;
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    _pageViewController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ChartPages oldWidget) {
    super.didUpdateWidget(oldWidget);
    load();
  }

  // @override
  @override
  Widget build(BuildContext context) {

    final pages = [
      Chart(
        isExpense: widget.isExpense,
        isExpanded: widget.isExpanded,
        shrinkChart: widget.shrinkChart,
        currency: widget.currency,
        dateFilterType: widget.dateFilterType,
        chartType: ChartType.categoryBarChart,
        categories: widget.categories,
      ),
      Chart(
        isExpense: widget.isExpense,
        isExpanded: widget.isExpanded,
        shrinkChart: widget.shrinkChart,
        currency: widget.currency,
        dateFilterType: widget.dateFilterType,
        startDate: widget.startDate,
        endDate: widget.endDate,
        chartType: ChartType.categoryLineChart,
        categories: widget.categories,
        transactions: widget.transactions,
      ),
      Chart(
        isExpense: widget.isExpense,
        isExpanded: widget.isExpanded,
        shrinkChart: widget.shrinkChart,
        currency: widget.currency,
        dateFilterType: widget.dateFilterType,
        startDate: widget.startDate,
        endDate: widget.endDate,
        chartType: ChartType.categoryStackBarChart,
        categories: widget.categories,
        transactions: widget.transactions,
      ),
    ];

    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSize.borderRadius),
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            PageView.builder(
              controller: _pageViewController,
              onPageChanged: _handlePageViewChanged,
              // itemCount: null or a very large number for infinite scroll.
              // When null, it behaves as an infinite list.
              itemCount: null,
              itemBuilder: (context, index) {
                // Use modulo operator to map the infinite index back to your actual pages.
                return pages[index % totalPages];
              },
            ),
            PageIndicator(
              tabController: _tabController,
              numOfPages: pages.length,
            )
          ],
        )
    );
  }
}

class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.tabController,
    required this.numOfPages,
  });

  final TabController tabController;
  final int numOfPages;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TabPageSelector(
            controller: tabController,
            color: colorScheme.surface,
            selectedColor: colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
