import 'package:flutter/material.dart';
import 'package:money_minder/style/app_color.dart';

import '../../models/currency.dart';
import 'budget_tile.dart';

class BudgetButton extends StatelessWidget {

  /// variable
  // props contains all the data required to build a category button
  final BudgetTileProp prop;
  // callback function when the categories button is pressed
  final void Function(BudgetTileProp) budgetOnPressed;
  final Currency mainCurrency;

  const BudgetButton({
    super.key,
    required this.prop,
    required this.budgetOnPressed,
    required this.mainCurrency,
    }
  );

  @override
  Widget build(BuildContext context) {

    double fraction = prop.budget == 0
        ? 0.00
        : 1 - (prop.actualAmount / prop.budget);
    fraction = fraction < 0 ? 0 : fraction;

    // button background color gradient reflect the portion of
    // expense over budget
    Widget buttonContent = Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: prop.isCircleBorder
            ? BoxShape.circle
            : BoxShape.rectangle
        ,
        color: prop.color,
        borderRadius: prop.isCircleBorder
          ? null
          : BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(
            prop.iconData,
            color: AppColor.lightIcon,
        ),
        onPressed: () {
          budgetOnPressed(prop);
        }
      )
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        buttonContent,
        const SizedBox(height: 4),
        Text(
          prop.label,
          style: TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        Column(
          children: [
            const SizedBox(height: 2),
            Text(
              '${mainCurrency.toString()} ${prop.actualAmount.toStringAsFixed(2)}',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(fontSize: 10),
            ),
          ],
        )
      ],
    );
  }
}
