import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:money_minder/components/statistics_page/statistics_cat_tile.dart';
import 'package:money_minder/components/statistics_page/statistics_helper.dart';

import '../../models/currency.dart';
import '../../models/date_filter.dart';
import '../../models/transaction.dart';
import '../../style/app_color.dart';
import '../../style/app_size.dart';
import '../categories_page/category_button.dart';
import '../categories_page/category_helper.dart';
import 'chart_pages.dart';

class StatisticsSheet extends StatefulWidget {

  final bool isExpense;
  final List<List<CategoryProp>> categories;
  final List<Transaction> transactions;
  final Currency mainCurrency;
  final DateFilterType dateFilterType;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime defaultDateForTransaction;
  final bool disabledAddBudget;
  final void Function() onTransactionReload;
  final Function(int) showCategoryTransactions;
  final void Function() onBudgetReload;
  final List<double> totalAmounts;

  const StatisticsSheet({
    super.key,
    required this.isExpense,
    required this.categories,
    required this.transactions,
    required this.mainCurrency,
    required this.dateFilterType,
    required this.startDate,
    required this.endDate,
    required this.disabledAddBudget,
    required this.onTransactionReload,
    required this.onBudgetReload,
    required this.totalAmounts,
    required this.defaultDateForTransaction,
    required this.showCategoryTransactions,
  });

  @override
  State<StatisticsSheet> createState() => _StatisticsSheetState();
}

class _StatisticsSheetState extends State<StatisticsSheet> {


  bool _isAscending = false;
  SortOptions _currentSortOption = SortOptions.percentage;
  List<CategoryProp> _category = [];
  List<double> _percentages = [];
  int _currentPage = 0;
  bool isExpanded = false;
  bool _showIndividual = false;

  void catTileOnPressed(CategoryProp prop) {
    CategoryHelper.showCategoryCard(
      context,
      prop,
      widget.mainCurrency,
      widget.startDate,
      widget.defaultDateForTransaction,
      widget.disabledAddBudget,
      widget.onTransactionReload,
      widget.onBudgetReload,
      widget.showCategoryTransactions,
    );
  }

  void onLoad() {
    setState(() {
      _category = List.from(widget.categories[widget.isExpense? 0: 1]);
      _percentages = StatisticsHelper.calculatePercentages(
          widget.categories[widget.isExpense? 0: 1], widget.totalAmounts[widget.isExpense ? 0 : 1]
      );
      StatisticsHelper.sortCategories(
          _category, _isAscending, _currentSortOption,
          widget.totalAmounts[widget.isExpense ? 0 : 1]);
    });
  }

  void shrinkChart() {
    setState(() {
      isExpanded = false;
    });
  }

  void updateCurrentPage(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  void initState() {
    super.initState();
    onLoad();
  }

  @override
  void didUpdateWidget(covariant StatisticsSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    onLoad();
  }

  @override
  Widget build(BuildContext context) {

    final bool isSmallScreen = MediaQuery.of(context).size.width <= 360;
    double expandedHeight = isSmallScreen ? 145 : 200;

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[

          SliverAppBar(

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(AppSize.borderRadius)),
            ),

            expandedHeight: expandedHeight,
            pinned: true,
            floating: false,
            snap: false,

            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double currentExtent = constraints.biggest.height;
                final double toolbarHeight = MediaQuery.of(context).padding.top + kToolbarHeight;
                final double expandedRange = expandedHeight - toolbarHeight;

                final double t = 1.0 - ((currentExtent - toolbarHeight) / expandedRange).clamp(0.0, 1.0);

                final double opacity = t; // Title fades in as app bar collapses

                return FlexibleSpaceBar(
                  title: Opacity(
                    opacity: opacity,
                    child: widget.isExpense
                        ? Text('Expenses')
                        : Text('Income'),
                  ),
                  centerTitle: true, // Center the title in the flexible space.
                  background: isExpanded ? null : ChartPages(
                      isExpanded: false,
                      isExpense: widget.isExpense,
                      categories: _category,
                      currency: widget.mainCurrency,
                      transactions: widget.transactions,
                      dateFilterType: widget.dateFilterType,
                      startDate: widget.startDate,
                      endDate: widget.endDate,
                      currentPage: _currentPage,
                      showIndividual: _showIndividual,
                      lineChartChangeType: () {
                        setState(() {
                          _showIndividual = !_showIndividual;
                        });
                      },
                      updateCurrentPage: updateCurrentPage,
                  )
                );
              },
            ),

            actions: [
              IconButton(
              icon: const Icon(Icons.fullscreen),
              onPressed: () {
                setState(() {
                  isExpanded = true;
                });
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return Dialog(
                        child: RotatedBox(
                            quarterTurns: 1,
                            child: ChartPages(
                                isExpanded: true,
                                isExpense: widget.isExpense,
                                shrinkChart: shrinkChart,
                                categories: _category,
                                currency: widget.mainCurrency,
                                transactions: widget.transactions,
                                dateFilterType: widget.dateFilterType,
                                startDate: widget.startDate,
                                endDate: widget.endDate,
                                currentPage: _currentPage,
                                showIndividual: _showIndividual,
                                lineChartChangeType: () {
                                  setState(() {
                                    _showIndividual = !_showIndividual;
                                  });
                                },
                                updateCurrentPage: updateCurrentPage,
                            )
                        )
                    );
                  }
                );
              })
            ],
          ),

          SliverToBoxAdapter(
            child: Padding( // Added Padding for better visual separation
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  DropdownButton<SortOptions>(
                    borderRadius: BorderRadius.circular(AppSize.borderRadius),
                    dropdownColor: AppColor.primary,
                    style: TextStyle(color: AppColor.darkText),
                    elevation: 0,
                    value: _currentSortOption,
                    icon: StatisticsHelper.sortOptionIcon[_currentSortOption],
                    iconSize: 20,
                    onChanged: (SortOptions? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _currentSortOption = newValue;
                          // Re-sort the categories when the sort option changes
                          StatisticsHelper.sortCategories(
                              _category, _isAscending, newValue, widget.totalAmounts[widget.isExpense ? 0 : 1]);
                        });
                      }
                    },
                    items: const <DropdownMenuItem<SortOptions>>[
                      DropdownMenuItem<SortOptions>(
                        value: SortOptions.alphabetical,
                        child: Text('Alphabetical'),
                      ),
                      DropdownMenuItem<SortOptions>(
                        value: SortOptions.budget,
                        child: Text('Budget'),
                      ),
                      DropdownMenuItem<SortOptions>(
                        value: SortOptions.actualAmount,
                        child: Text('Amount'),
                      ),
                      DropdownMenuItem<SortOptions>(
                        value: SortOptions.position,
                        child: Text('Position'),
                      ),
                      DropdownMenuItem<SortOptions>(
                        value: SortOptions.percentage,
                        child: Text('Percentage'),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: _isAscending
                        ? const Icon(CupertinoIcons.sort_up) // Consistent sorting icon
                        : const Icon(CupertinoIcons.sort_down), // Consistent sorting icon
                    onPressed: () {
                      setState(() {
                        _isAscending = !_isAscending;
                        // Re-sort the categories when the sort order changes
                        StatisticsHelper.sortCategories(
                            _category, _isAscending, _currentSortOption, widget.totalAmounts[widget.isExpense ? 0 : 1]);
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          // show each category
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                return StatisticsCatTile(
                    prop: _category[index],
                    mainCurrency: widget.mainCurrency,
                    onPressed: catTileOnPressed,
                    totalAmount: widget.totalAmounts[widget.isExpense ? 0 : 1],
                    percentage: _percentages[_category[index].position],
                );
                //     return StatisticsCatTile(prop: category[index]);
              },
              childCount: _category.length, // Number of items in the list
            ),
          ),
        ],
      ),
    );
  }
}
