import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:money_minder/components/categories_page/categories_selection_sheet.dart';

import '../models/category.dart';
import '../style/app_color.dart';
import '../style/app_size.dart';

// use this to construct the topContent of the calculator sheet
class CategoryTopCard extends StatelessWidget {

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
  Widget build(BuildContext context) {
    Category category = initialCategory;

    Widget buttonContent = SizedBox(
      width: 40.w,
      height: 40.h,
      child: Icon(category.icon.icon, size: AppSize.bigIcon.sp,)
    );

    return MaterialButton(
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(topLeft ? AppSize.borderRadius : 0),
          topRight: Radius.circular(topRight ? AppSize.borderRadius : 0),
        ),
      ),
      color: category.color,
      disabledColor: category.color,
      disabledTextColor: AppColor.lightText,
      onPressed: !isTappable ? null : () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: AppColor.secondary,
          builder: (context) {
            return CategoriesSelectionSheet(isExpense: category.isExpense, onSelect: onPressed);
          }
      ),
      child: Stack(
        children: [
          Container(
            width: width,
            decoration: BoxDecoration(
                color : Colors.transparent,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(topLeft ? AppSize.borderRadius : 0),
                  topRight: Radius.circular(topRight ? AppSize.borderRadius : 0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(AppSize.smallPadding.r),
                  child: Text(
                      '${topLeft ? "From" : "To"} Category',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: AppSize.heading3.sp,
                      )
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: AppSize.smallPadding.w,
                    right: AppSize.smallPadding.w,
                    bottom: AppSize.smallPadding.h,
                  ),
                  child: Text(
                      category.name,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: (AppSize.heading1 * 1.15).sp,
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
