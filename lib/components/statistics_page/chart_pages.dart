import 'package:flutter/material.dart';
import 'package:money_minder/components/categories_page/category_button.dart';
import 'package:money_minder/components/statistics_page/bar_chart.dart';

import '../../style/app_size.dart';
import 'chart.dart';

class ChartPages extends StatefulWidget {
  const ChartPages({
    super.key,
    required this.isExpanded,
    this.shrinkChart,
    required this.categories,
    required this.totalPages,
    required this.currentPage,
    required this.updateCurrentPage,
  });

  final bool isExpanded;
  final void Function()? shrinkChart;
  final List<CategoryProp> categories;
  final int totalPages;
  final int currentPage;
  final void Function(int) updateCurrentPage;

  @override
  State<ChartPages> createState() => _ChartPagesState();
}

class _ChartPagesState extends State<ChartPages> with TickerProviderStateMixin {

  late PageController _pageViewController;
  late TabController _tabController;

  void _handlePageViewChanged(int index) {
    _tabController.index = index % widget.totalPages;
    _pageViewController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    widget.updateCurrentPage(index);
  }

  @override
  void initState() {
    super.initState();
    _pageViewController = PageController(initialPage: widget.currentPage == 0
        ? widget.totalPages * 1000
        : widget.currentPage);
    _tabController = TabController(length: widget.totalPages, vsync: this);
    _tabController.index = widget.currentPage % widget.totalPages;
  }

  @override
  void dispose() {
    _pageViewController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // @override
  @override
  Widget build(BuildContext context) {

    final bool isSmallScreen = MediaQuery.of(context).size.width <= 360;
    final double height = widget.isExpanded
        ? MediaQuery.of(context).size.width * 0.8
        : isSmallScreen ? 145 : 200 - AppSize.smallPadding;
    final double width = widget.isExpanded
        ? MediaQuery.of(context).size.height * 0.8
        : MediaQuery.of(context).size.width * 0.9;
    final aspectRatio = width / (height - 50);
    final pages = [
      Chart(
        isExpanded: widget.isExpanded,
        shrinkChart: widget.shrinkChart,
        child: CategoryBarChart(
          aspectRatio: aspectRatio,
          isExpanded: widget.isExpanded,
          categories: widget.categories,
        ),
      ),
      Chart(
        isExpanded: widget.isExpanded,
        shrinkChart: widget.shrinkChart,
        child: Center(child: Text("Second Page")),
      ),
      Chart(
        isExpanded: widget.isExpanded,
        shrinkChart: widget.shrinkChart,
        child: Center(child: Text("Third Page")),
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
                return pages[index % pages.length];
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
