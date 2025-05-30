import 'package:flutter/material.dart';
import 'package:money_minder/components/budget_page/show_money.dart';
import '../../style/app_color.dart';
import '../../style/app_size.dart';
import 'budget_helper.dart';
import 'budget_tile.dart';

class MainBudgetTile extends BudgetTile {

  const MainBudgetTile({
    super.key,
    required super.prop,
  });

  @override
  Widget build(BuildContext context) {

    final double topFactor = 1.5;
    final double bottomFactor = 1.0;
    double fraction = prop.budget <= 0
        ? 0.02
        : prop.actualAmount / prop.budget;
    fraction = fraction < 0.02 ? 0.02 : fraction;
    Color leftColor = BudgetHelper.lightenColor(prop.color, 0.75);
    Color rightColor = BudgetHelper.lightenColor(prop.color, 0.9);

    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSize.borderRadius),
          gradient: LinearGradient(
              colors: [leftColor, leftColor, rightColor, rightColor],
              stops: [0, fraction, fraction, 1]
          )
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSize.smallPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Column(
              spacing: 5,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prop.label,
                  style: TextStyle(
                    fontSize: AppSize.heading3 * topFactor,
                    color: AppColor.darkText,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ShowMoney(
                  mainCurrency: prop.mainCurrency,
                  amount: prop.actualAmount,
                  text: BudgetHelper.textMap[prop.type]!,
                  color: prop.color,
                  factor: bottomFactor,
                )
              ],
            ),
            Column(
              spacing: 5,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ShowMoney(
                  mainCurrency: prop.mainCurrency,
                  amount: prop.budget - prop.actualAmount,
                  text: "",
                  color: prop.color,
                  factor: topFactor,
                ),
                ShowMoney(
                  mainCurrency: prop.mainCurrency,
                  amount: prop.budget,
                  text: "budgeted",
                  color: prop.color,
                  factor: bottomFactor,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}