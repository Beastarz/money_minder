import 'package:flutter/material.dart';

import '../../style/app_size.dart';
import 'chart.dart';

class ChartPages extends StatefulWidget {
  const ChartPages({
    super.key,
    required this.isExpanded,
    this.shrinkChart,
    required this.currentPage,
    required this.updateCurrentPage,
  });

  final bool isExpanded;
  final void Function()? shrinkChart;
  final int currentPage;
  final void Function(int) updateCurrentPage;

  @override
  State<ChartPages> createState() => _ChartPagesState();
}

class _ChartPagesState extends State<ChartPages> with TickerProviderStateMixin {

  late PageController _pageViewController;
  late TabController _tabController;
  late List<Widget> pages = [
    Chart(
      title: "First Page",
      isExpanded: widget.isExpanded,
      shrinkChart: widget.shrinkChart,
    ),
    Chart(
      title: "Second Page",
      isExpanded: widget.isExpanded,
      shrinkChart: widget.shrinkChart,
    ),
    Chart(
      title: "Third Page",
      isExpanded: widget.isExpanded,
      shrinkChart: widget.shrinkChart,
    ),
  ];

  void _handlePageViewChanged(int index) {
    _tabController.index = index % pages.length;
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
        ? pages.length * 1000
        : widget.currentPage);
    _tabController = TabController(length: pages.length, vsync: this);
    _tabController.index = widget.currentPage % pages.length;
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
