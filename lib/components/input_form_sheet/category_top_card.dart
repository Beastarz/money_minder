import 'package:flutter/material.dart';
import 'package:money_minder/components/categories_page/categories_selection_sheet.dart';
import 'package:money_minder/repositories/categories_repositories.dart';

import '../../models/category.dart';
import '../../style/app_color.dart';
import '../../style/app_size.dart';

// use this to construct the topContent of the calculator sheet
class CategoryTopCard extends StatefulWidget {

  /// variable
  final double width; // width of the card
  final Category initialCategory; // initial category
  final bool topRight; // whether to curve topRight corner
  final bool topLeft; // whether to curve topLeft corner
  final bool isTappable;
  final void Function(Category) onPressed; // callback function when the button is pressed

  const CategoryTopCard({
    super.key,
    required this.width,
    required this.initialCategory,
    required this.onPressed,
    this.isTappable = true,
    this.topRight = false,
    this.topLeft = false,
  });

  @override
  State<CategoryTopCard> createState() => _CategoryTopCardState();
}

class _CategoryTopCardState extends State<CategoryTopCard> {
  List<Category> expenses = [];
  List<Category> incomes = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  void _fetchCategories() async {
    List<Category> res1 = await CategoriesRepositories.instance.getCategoriesByType(true);
    List<Category> res2 = await CategoriesRepositories.instance.getCategoriesByType(false);
    setState(() {
      expenses = res1;
      incomes = res2;
    });
  }

  @override
  Widget build(BuildContext context) {
    Category category = widget.initialCategory;

    Widget buttonContent = SizedBox(
      width: 40,
      height: 40,
      child: category.icon
    );

    return MaterialButton(
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(widget.topLeft ? AppSize.borderRadius : 0),
          topRight: Radius.circular(widget.topRight ? AppSize.borderRadius : 0),
        ),
      ),
      color: category.color,
      disabledColor: category.color,
      disabledTextColor: AppColor.lightText,
      onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: AppColor.secondary,
          builder: (context) {
            return CategoriesSelectionSheet(expenses: expenses, incomes: incomes, onSelect: widget.onPressed);
          }
      ),
      child: Stack(
        children: [
          Container(
            width: widget.width,
            decoration: BoxDecoration(
                color : Colors.transparent,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(widget.topLeft ? AppSize.borderRadius : 0),
                  topRight: Radius.circular(widget.topRight ? AppSize.borderRadius : 0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(AppSize.smallPadding),
                  child: Text(
                      '${widget.topLeft ? "From" : "To"} Category',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: AppSize.heading3,
                      )
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: AppSize.smallPadding,
                    right: AppSize.smallPadding,
                    bottom: AppSize.smallPadding,
                  ),
                  child: Text(
                      category.label,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: AppSize.heading1 * 1.15,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                      )
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 5,
            right: 5,
            child: buttonContent,
          ),
        ]
      ),
    );
  }
}
