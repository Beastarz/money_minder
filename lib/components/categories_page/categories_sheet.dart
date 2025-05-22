import 'package:flutter/material.dart';
import 'package:money_minder/components/categories_page/categories_page_helper.dart';

import '../../style/app_size.dart';
import 'categories_button.dart';

class CategoriesSheet extends StatelessWidget {

  /// variable
  // track if currently showing expense or income
  final bool isExpense;
  // the index of the pie data that is currently selected
  final int pieTouchedIndex;

  const CategoriesSheet({
    super.key,
    required this.isExpense,
    required this.pieTouchedIndex,
  });

  @override
  Widget build(BuildContext context) {

    // check if screen is small
    final bool isSmallScreen = MediaQuery.of(context).size.width <= 360;
    // generate list of categories
    final List<CategoriesButtonProps> categories =
      CategoriesPageHelper.getCategoriesList(isExpense);


    return Expanded( // Use Expanded to make the grid take up remaining space
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppSize.smallPadding),
          child: GridView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 0.8,
              crossAxisCount: isSmallScreen ? 3 : 4,
              crossAxisSpacing: 4.0,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              categories[index].pieTouchedIndex = pieTouchedIndex;
              return CategoriesButton(
                props: categories[index],
              );
            },
          ),
        ),
      ),
    );
  }
}