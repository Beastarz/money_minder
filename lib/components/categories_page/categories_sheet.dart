import 'package:flutter/material.dart';

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

  const CategoriesSheet({
    super.key,
    required this.isExpense,
    required this.pieTouchedIndex,
    required this.categoriesButtonOnPressed,
    required this.categories,
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
      itemCount: categories.length * 5,
      itemBuilder: (context, index) {
        categories[index % 4].pieTouchedIndex = pieTouchedIndex;
        return CategoriesButton(
          props: categories[index % 4],
          categoriesButtonOnPressed: categoriesButtonOnPressed,
        );
      },
    );
  }
}
