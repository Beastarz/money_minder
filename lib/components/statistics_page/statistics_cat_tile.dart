import 'package:flutter/material.dart';
import 'package:money_minder/components/categories_page/category_button.dart';
import 'package:money_minder/components/categories_page/category_helper.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../models/currency.dart';
import '../../style/app_color.dart';
import '../../style/app_size.dart';
import '../../utils/balance_text.dart';

class StatisticsCatTile extends StatelessWidget {

  final CategoryProp prop;
  final Currency mainCurrency;
  final void Function(CategoryProp) onPressed;
  final double totalAmount;
  final double percentage;

  const StatisticsCatTile({
    super.key,
    required this.prop,
    required this.mainCurrency,
    required this.onPressed,
    required this.totalAmount,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {

    final double shownPercentage = totalAmount == 0
      ? 0
      : prop.actualAmount / totalAmount;
    // Calculate the color gradient
    final double fraction = prop.budget == 0
      ? 1
      : prop.actualAmount / prop.budget;
    Color topColor = prop.color.withAlpha((0.3 * 255).round());
    Color bottomColor = prop.color;
    final bool exceed = (prop.isExpense
        ? prop.budget < prop.actualAmount
        : prop.actualAmount < prop.budget) && prop.budget != 0;

    Widget categoryIcon = Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [bottomColor, bottomColor, topColor, topColor],
            stops: [0.0, fraction, fraction, 1],
          ),
          border: Border.all(
            color: prop.color,
            width: 2.0,
          ),
          shape: BoxShape.circle,
        ),
        child: prop.icon
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      color: CategoryHelper.lightenColor(prop.color, 0.9),
      child: MaterialButton(
        onPressed: () {onPressed(prop);},
        padding: const EdgeInsets.all(8.0),
        splashColor: CategoryHelper.lightenColor(prop.color, 0.75),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSize.borderRadius),
        ),
        child: LinearPercentIndicator(
          animation: true,
          lineHeight: 20.0,
          percent: percentage,
          backgroundColor: AppColor.tertiary,
          progressColor: CategoryHelper.lightenColor(prop.color, 0.5),
          center: Text(
            "${(shownPercentage * 100).toStringAsFixed(2)}%",
            style: TextStyle(fontSize: 12.0),
          ),
          leading: Column(
            children: [
              categoryIcon,
              SizedBox(
                width: 50,
                child: Text(
                  prop.label,
                  style: TextStyle(
                    color: prop.color,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              )
            ],
          ),
          trailing: SizedBox(
            width: 100,
            child: Column(
              children: [
                BalanceText(
                  balance: prop.actualAmount,
                  currencyName: mainCurrency.toString(),
                  fontColor: exceed ? AppColor.darkText : prop.color,
                  size: 16,
                  fillColor: exceed
                      ? CategoryHelper.lightenColor(prop.color, 0.3)
                      : Colors.transparent,
                ),
                prop.budget > 0
                ? BalanceText(
                  balance: prop.budget,
                  currencyName: mainCurrency.toString(),
                  fontColor: prop.color,
                  size: 14,
                )
                : SizedBox.shrink(),
              ],
            ),
          ),
          barRadius: Radius.circular(10),
        ),
      ),
    );
  }
}
