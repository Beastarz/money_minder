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

  const StatisticsCatTile({
    super.key,
    required this.prop,
    required this.mainCurrency,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {

    final double percentage = prop.budget == 0
        ? prop.actualAmount > 0 ? 1 : 0
        : prop.actualAmount / prop.budget;
    final double progress = percentage > 1 ? 1 : percentage;

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
          percent: progress,
          backgroundColor: AppColor.tertiary,
          progressColor: CategoryHelper.lightenColor(prop.color, 0.5),
          center: Text(
            "${(percentage * 100).toStringAsFixed(2)}%",
            style: TextStyle(fontSize: 12.0),
          ),
          leading: Column(
            children: [
              Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: prop.color,
                    shape: BoxShape.circle,
                  ),
                  child: prop.icon
              ),
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
                  fontColor: prop.color,
                  size: 16,
                  textWidth: 70,
                ),
                BalanceText(
                  balance: prop.budget,
                  currencyName: mainCurrency.toString(),
                  fontColor: prop.color,
                  size: 12,
                  textWidth: 70,
                ),
              ],
            ),
          ),
          barRadius: Radius.circular(10),
        ),
      ),
    );
  }
}
