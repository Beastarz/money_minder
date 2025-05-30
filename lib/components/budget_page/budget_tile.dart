import 'package:flutter/material.dart';
import 'package:money_minder/components/budget_page/show_money.dart';

import '../../models/currency.dart';
import '../../style/app_color.dart';
import '../../style/app_size.dart';
import '../input_form_sheet/input_form.dart';
import '../input_form_sheet/input_form_helper.dart';
import '../input_form_sheet/input_form_sheet.dart';
import '../input_form_sheet/top_card.dart';
import 'budget_helper.dart';
import 'main_budget_tile.dart';

class BudgetTileProp {
  final String label;
  final Color color;
  final double actualAmount;
  final double budget;
  final String type;
  final bool isCircleBorder;
  final Currency mainCurrency;
  final IconData? iconData;

  const BudgetTileProp({
    required this.label,
    required this.color,
    required this.actualAmount,
    required this.budget,
    required this.type,
    required this.isCircleBorder,
    required this.mainCurrency,
    this.iconData,
  });
}

class BudgetTile extends StatelessWidget {

  final BudgetTileProp prop;
  final bool topCurve;
  final bool bottomCurve;

  const BudgetTile({
    super.key,
    required this.prop,
    this.topCurve = false,
    this.bottomCurve = false,
  });

  void onPressed(BuildContext context) {

    final bool isSmallScreen = MediaQuery.of(context).size.width <= 360;
    final double titleSize = (isSmallScreen ? AppSize.heading2 : AppSize.heading1) * 1.5;

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (sheetContext) {
          return InputFormSheet(
            // Define the button layout as seen in the image
              inputForm: InputForm(
                  buttonProps: InputFormHelper.convertToCalButProps([
                    '÷', '7', '8', '9', 'C',
                    'x', '4', '5', '6', '<',
                    '-', '1', '2', '3', 'budget',
                    '+', '\$', '0', '.',
                  ], {
                    '<': Icons.backspace_outlined,
                    'budget': Icons.scale_outlined,
                    '✓': Icons.check,
                  }
                ),
                showNotes: false,
                defaultValue: prop.budget,
                mainCurrency: prop.mainCurrency,
              ),
              topContent: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppSize.borderRadius)
                  ),
                ),
                child: Row(
                  children: [
                    TopCard(
                      width: MediaQuery.of(context).size.width,
                      topRight: true,
                      topLeft: true,
                      title: Text(
                        prop.label,
                        style: TextStyle(
                          fontSize: titleSize,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      content: MainBudgetTile(
                        prop: prop
                      ),
                      backgroundColor: prop.color,
                      icon: Icon(
                        prop.iconData,
                        size: AppSize.bigIcon,
                      ),
                      isTappable: false,
                      // cannot be pressed
                      onPressed: null,
                    )
                    ]
                ),
              )
          );
        }
    );
  }

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
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(topCurve ? AppSize.borderRadius : 0),
              bottom: Radius.circular(bottomCurve ? AppSize.borderRadius : 0),
          ),
          gradient: LinearGradient(
              colors: [leftColor, leftColor, rightColor, rightColor],
              stops: [0, fraction, fraction, 1]
          )
      ),
      child: MaterialButton(
        onPressed: () {onPressed(context);},
        padding: const EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(topCurve ? AppSize.borderRadius : 0),
              bottom: Radius.circular(bottomCurve ? AppSize.borderRadius : 0),
            )
        ),
        child: Padding(
          padding: EdgeInsets.all(AppSize.smallPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: 5,
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: prop.isCircleBorder
                        ? BoxShape.circle
                        : BoxShape.rectangle,
                      borderRadius: prop.isCircleBorder
                        ? null
                        : BorderRadius.circular(AppSize.borderRadius),
                      color: prop.color,
                    ),
                    child: Icon(
                        prop.iconData,
                        color: AppColor.primary,
                    ),
                  ),
                  Column(
                    spacing: 5,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prop.label,
                        style: TextStyle(
                          fontSize: AppSize.heading3 * topFactor,
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
      ),
    );
  }
}

