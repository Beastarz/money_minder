import 'package:flutter/material.dart';
import 'package:money_minder/components/budget_page/budget_circular_bar.dart';
import 'package:money_minder/components/categories_page/category_button.dart';

import '../../models/currency.dart';
import '../../style/app_color.dart';
import '../../style/app_size.dart';
import 'category_helper.dart';

class CategoryCard extends StatelessWidget {

  final CategoryProp prop;
  final Currency currency;
  final bool disabledAddBudget;
  final Function(int) showCategoryTransactions;
  final void Function(CategoryProp) showTransactionInputForm;
  final void Function(CategoryProp) showBudgetInputForm;

  const CategoryCard({
    super.key,
    required this.prop,
    required this.currency,
    required this.disabledAddBudget,
    required this.showTransactionInputForm,
    required this.showBudgetInputForm,
    required this.showCategoryTransactions,
  });

  @override
  Widget build(BuildContext context) {

    Color splashColor = CategoryHelper.lightenColor(prop.color, 0.75);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(AppSize.smallPadding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSize.borderRadius),
          color: AppColor.secondary,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MaterialButton(
              onPressed: disabledAddBudget
                ? null
                : () {
                Navigator.pop(context);
                showBudgetInputForm(prop);
              },
              splashColor: splashColor,
              disabledTextColor: AppColor.darkText,
              disabledColor: AppColor.secondary,
              child: Container(
                padding: EdgeInsets.only(top: AppSize.smallPadding),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSize.borderRadius),
                ),
                child: BudgetCircularBar(
                  prop: prop,
                  disabledBudget: disabledAddBudget,
                  currency: currency,
                ),
              )
            ),
            MaterialButton(
              onPressed: () {
                Navigator.pop(context);
                showTransactionInputForm(prop);
              },
              splashColor: splashColor,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Add Transaction"),
                  SizedBox(width: AppSize.smallPadding),
                  Icon(Icons.list_alt_outlined),
                ]
              )
            ),
            MaterialButton(
                onPressed: () {
                  showCategoryTransactions(prop.id);
                  Navigator.pop(context);
                },
                splashColor: splashColor,
                child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("View Transactions"),
                      SizedBox(width: AppSize.smallPadding),
                      Icon(Icons.remove_red_eye_outlined),
                    ]
                )
            )
          ]
        ),
      ),
    );
  }
}
