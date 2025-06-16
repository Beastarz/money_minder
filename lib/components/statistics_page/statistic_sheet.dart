import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:money_minder/components/statistics_page/statistics_cat_tile.dart';
import 'package:money_minder/components/statistics_page/statistics_helper.dart';

import '../../models/currency.dart';
import '../../style/app_color.dart';
import '../../style/app_size.dart';
import '../categories_page/category_button.dart';
import '../categories_page/category_helper.dart';

class StatisticsSheet extends StatefulWidget {

  final bool isExpense;
  final List<List<CategoryProp>> categories;
  final Currency mainCurrency;
  final DateTime startDate;
  final DateTime defaultDateForTransaction;
  final bool disabledAddBudget;
  final void Function() onAddTransactionReload;
  final void Function() onBudgetReload;

  const StatisticsSheet({
    super.key,
    required this.isExpense,
    required this.categories,
    required this.mainCurrency,
    required this.startDate,
    required this.disabledAddBudget,
    required this.onAddTransactionReload,
    required this.onBudgetReload,
    required this.defaultDateForTransaction,
  });

  @override
  State<StatisticsSheet> createState() => _StatisticsSheetState();
}

class _StatisticsSheetState extends State<StatisticsSheet> {


  bool _isAscending = false;
  SortOptions _currentSortOption = SortOptions.percentage;

  void catTileOnPressed(CategoryProp prop) {
    CategoryHelper.showCategoryCard(
      context,
      prop,
      widget.mainCurrency,
      widget.startDate,
      widget.defaultDateForTransaction,
      widget.disabledAddBudget,
      widget.onAddTransactionReload,
      widget.onBudgetReload,
    );
  }

  @override
  Widget build(BuildContext context) {


    final bool isSmallScreen = MediaQuery.of(context).size.width <= 360;
    double expandedHeight = isSmallScreen ? 145 : 200;
    List<CategoryProp> category = widget.categories[widget.isExpense ? 0 : 1];
    StatisticsHelper.sortCategories(category, _isAscending, _currentSortOption);

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
                        ? Text('Statistics Expense Page')
                        : Text('Statistics Income Page'),
                  ),
                  centerTitle: true, // Center the title in the flexible space.
                  background: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSize.borderRadius),
                    ),
                    child: Center(child: Text("Statistics..."))
                  ),
                );
              },
            ),

            // Actions on the right side of the app bar.
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.fullscreen),
                onPressed: () {

                  // Handle settings action
                  /// TODO: expand the chart

                },
              ),
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
                          StatisticsHelper.sortCategories(category, _isAscending, newValue);
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
                        StatisticsHelper.sortCategories(category, _isAscending, _currentSortOption);
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
                    prop: category[index],
                    mainCurrency: widget.mainCurrency,
                    onPressed: catTileOnPressed,
                );
                //     return StatisticsCatTile(prop: category[index]);
              },
              childCount: category.length, // Number of items in the list
            ),
          ),
        ],
      ),
    );
  }
}
