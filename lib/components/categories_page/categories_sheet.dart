import 'package:flutter/material.dart';
import 'package:money_minder/models/currency.dart';

import '../../style/app_size.dart';
import 'categories_button.dart';

class CategoriesSheet extends StatelessWidget {

  /// variable
  // track if currently showing expense or income
  final bool isExpense;
  // the index of the pie data that is currently selected
  final int pieTouchedIndex;
  // callback function when the categories button is pressed
  final void Function(CategoryButtonProps) categoriesButtonOnPressed;
  // the list of categories to be shown
  final List<CategoryButtonProps> categories;
  final Currency mainCurrency;

  const CategoriesSheet({
    super.key,
    required this.isExpense,
    required this.pieTouchedIndex,
    required this.categoriesButtonOnPressed,
    required this.categories,
    required this.mainCurrency,
  });

  @override
  Widget build(BuildContext context) {

    // check if screen is small
    final bool isSmallScreen = MediaQuery.of(context).size.width <= 360;


    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.all(AppSize.smallPadding),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: 0.8,
        crossAxisCount: isSmallScreen ? 3 : 4,
        crossAxisSpacing: 4.0,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        categories[index].pieTouchedIndex = pieTouchedIndex;
        return CategoriesButton(
          prop: categories[index],
          categoriesButtonOnPressed: categoriesButtonOnPressed,
          mainCurrency: mainCurrency,
        );
      },
    );
  }
}
