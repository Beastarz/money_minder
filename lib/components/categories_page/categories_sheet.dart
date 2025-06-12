import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
import 'package:money_minder/models/currency.dart';

import '../../style/app_size.dart';
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
  final void Function() onCategoryReload;
  final void Function() resetPieIndex;

  const CategoriesSheet({
    super.key,
    required this.isExpense,
    required this.pieTouchedIndex,
    required this.categoriesButtonOnPressed,
    required this.categories,
    required this.mainCurrency,
    required this.onCategoryReload,
    required this.resetPieIndex,
  });

  @override
  State<CategoriesSheet> createState() => _CategoriesSheetState();
}

class _CategoriesSheetState extends State<CategoriesSheet> {

  // Declare final variables to be initialized in initState
  late final GlobalKey _gridViewKey;
  late final ScrollController _scrollController;
  late List<CategoryProp> _categories;
  int _fromPosition = 0;
  int _toPosition = 0;

  void updateDataBase() async {
    await CategoryHelper.swapPosition(
        _fromPosition,
        _toPosition,
        widget.categories);
    widget.onCategoryReload();
  }

  @override
  void initState() {
    super.initState();
    _gridViewKey = GlobalKey();
    _scrollController = ScrollController();
    _categories = widget.categories;
  }

  @override
  void didUpdateWidget(covariant CategoriesSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categories != widget.categories) {
      setState(() {
        _categories = widget.categories;
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

    return ReorderableBuilder.builder(
      key: Key(_gridViewKey.toString()),
      onDragStarted: (fromPosition) {
        widget.resetPieIndex();
        setState(() {
          _fromPosition = fromPosition;
        });
      },
      onReorder: (ReorderedListFunction<CategoryProp> reorderedListFunction) {
        setState(() {
          _categories = reorderedListFunction(_categories);
        });
        updateDataBase();
      },
      onDragEnd: (toPosition) {
        setState(() {
          _toPosition = toPosition;
        });
      },
      dragChildBoxDecoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.2 * 255).round()), // A subtle shadow
            blurRadius: 15.0,
            spreadRadius: -10.0,
            offset: Offset(0, 5),
          ),
        ],
      ),
      scrollController: _scrollController,
      reverse: false,
      lockedIndices: [_categories.length - 1], // add button cannot be moved
      nonDraggableIndices: [_categories.length - 1], // add button cannot be dragged
      childBuilder: (itemBuilder) {
        return GridView.builder(
          key: _gridViewKey,
          physics: const NeverScrollableScrollPhysics(),
          controller: _scrollController,
          shrinkWrap: true,
          padding: EdgeInsets.all(AppSize.smallPadding),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: 0.8,
            crossAxisCount: isSmallScreen ? 3 : 4,
            crossAxisSpacing: 4.0,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final categoryWithUpdatedIndex = CategoryProp(
              id: _categories[index].id,
              label: _categories[index].label,
              actualAmount: _categories[index].actualAmount,
              icon: _categories[index].icon,
              isExpense: _categories[index].isExpense,
              pieTouchedIndex: widget.pieTouchedIndex,
              budget: _categories[index].budget,
              color: _categories[index].color,
              position: _categories[index].position,
              isAddButton: _categories[index].isAddButton,
            );

            return itemBuilder(
              CategoryButton(
                key: Key(categoryWithUpdatedIndex.id.toString()),
                prop: categoryWithUpdatedIndex,
                categoriesButtonOnPressed: widget.categoriesButtonOnPressed,
                mainCurrency: widget.mainCurrency,
              ),
              index
            );
          },
        );
      },
      itemCount: _categories.length, // Use widget.categories
    );
  }
}
