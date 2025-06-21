import 'package:flutter/material.dart';
import 'package:money_minder/models/currency.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

import 'category_button.dart';
import 'category_helper.dart';

class CategoriesSheet extends StatefulWidget { // Changed back to StatefulWidget

  /// variable
  // track if currently showing expense or income
  final bool isExpense;
  // the index of the pie data that is currently selected
  final int pieTouchedIndex;
  // callback function when the categories button is pressed
  final void Function(CategoryProp) categoriesButtonOnPressed;
  // the list of categories to be shown
  final List<CategoryProp> categories;
  final Currency mainCurrency;
  final Future<void> Function() onCategoryReload;
  final Future<void> Function() onTransactionReload;
  final Future<void> Function() onBudgetReload;
  final void Function() resetPieIndex;

  const CategoriesSheet({
    super.key,
    required this.isExpense,
    required this.pieTouchedIndex,
    required this.categoriesButtonOnPressed,
    required this.categories,
    required this.mainCurrency,
    required this.onCategoryReload,
    required this.onTransactionReload,
    required this.onBudgetReload,
    required this.resetPieIndex,
  });

  @override
  State<CategoriesSheet> createState() => _CategoriesSheetState();
}

class _CategoriesSheetState extends State<CategoriesSheet> {

  // Declare final variables to be initialized in initState
  // late final GlobalKey _gridViewKey;
  late final ScrollController _scrollController;
  late List<CategoryProp> cateogry;
  bool isUpdating = false;
  // int _fromPosition = 0;
  // int _toPosition = 0;

  void updatePosition(int from, int to) async {
    setState(() {
      isUpdating = true;
    });
    await CategoryHelper.movePosition(
        from,
        to,
        widget.categories);
    await widget.onCategoryReload();
    await widget.onTransactionReload();
    setState(() {
      isUpdating = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    cateogry = List.from(widget.categories);
  }

  @override
  void didUpdateWidget(covariant CategoriesSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categories != widget.categories && !isUpdating) {
      setState(() {
        cateogry = List.from(widget.categories);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // check if screen is small
    final bool isSmallScreen = MediaQuery.of(context).size.width <= 360;

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: ReorderableGridView.count(
        onReorder: (int fromPosition, int toPosition) {
          setState(() {
            cateogry.insert(toPosition, cateogry.removeAt(fromPosition));
          });
          updatePosition(fromPosition, toPosition);
        },
        onDragStart: (int position) {
          widget.resetPieIndex();
        },
        controller: _scrollController,
        crossAxisCount: isSmallScreen ? 3 : 4,
        crossAxisSpacing: 4.0,
        childAspectRatio: 0.8,
        shrinkWrap: true,
        placeholderBuilder: (from, to, child) {
          return Opacity(opacity: 0.2, child: child);
        },
        dragWidgetBuilderV2: DragWidgetBuilderV2(
            isScreenshotDragWidget: true,
            builder: (index, child, screenshot) {
              // return child;
              return Transform.scale(
                scale: 1.1,
                child: Material(
                  color: Colors.transparent,
                  child: Theme( // Explicitly provide the current Theme
                    data: Theme.of(context), // Use the theme from the original context
                    child: child,
                  ),
                ),
              );
            }
        ),
        footer: [CategoryButton(
          key: const ValueKey('add_category_button_unique_id'),
          prop: cateogry.last,
          categoriesButtonOnPressed: widget.categoriesButtonOnPressed,
          mainCurrency: widget.mainCurrency,
          onCategoryReload: widget.onCategoryReload,
          onTransactionReload: widget.onTransactionReload,
          onBudgetReload: widget.onBudgetReload,
        )],
        children: cateogry.sublist(0, cateogry.length - 1).map(
          (cat) {
            return CategoryButton(
              key: Key(cat.id.toString()),
              prop: CategoryProp(
                id: cat.id,
                label: cat.label,
                actualAmount: cat.actualAmount,
                icon: cat.icon,
                isExpense: cat.isExpense,
                pieTouchedIndex: widget.pieTouchedIndex,
                budget: cat.budget,
                color: cat.color,
                position: cat.position,
                isAddButton: cat.isAddButton,
              ),
              categoriesButtonOnPressed: widget.categoriesButtonOnPressed,
              mainCurrency: widget.mainCurrency,
              onCategoryReload: widget.onCategoryReload,
              onTransactionReload: widget.onTransactionReload,
              onBudgetReload: widget.onBudgetReload,
            );
          }
        ).toList(),
      ),
    );
  }
}
