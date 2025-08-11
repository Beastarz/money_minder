import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:money_minder/components/categories_page/category_button.dart';

import '../../models/currency.dart';
import '../../style/app_color.dart';
import '../../utils/balance_text.dart';

class BudgetCircularBar extends StatelessWidget {

  final CategoryProp prop;
  final bool disabledBudget;
  final Currency currency;

  const BudgetCircularBar({
    super.key,
    required this.prop,
    required this.disabledBudget,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {

    final double percentage = prop.budget == 0
        ? prop.actualAmount > 0 ? 100 : 0
        : prop.actualAmount / prop.budget * 100;
    final double progress = percentage > 100 ? 100 : percentage;
    final isSmallScreen = MediaQuery.of(context).size.width <= 360;
    final ValueNotifier<double> valueNotifier = ValueNotifier(0);
    final double textWidth = MediaQuery.of(context).size.width * (
        isSmallScreen ? 0.15 : 0.2
    );

    return DashedCircularProgressBar.aspectRatio(
      aspectRatio: 1, // width ÷ height
      valueNotifier: valueNotifier,
      progress: progress,
      startAngle: 225,
      sweepAngle: 270,
      foregroundColor: prop.color,
      backgroundColor: AppColor.tertiary,
      foregroundStrokeWidth: 15.sp,
      backgroundStrokeWidth: 15.sp,
      animation: true,
      seekSize: 6,
      seekColor: AppColor.primary,
      animationDuration: Duration(seconds: 1),
      child: Center(
        child: ValueListenableBuilder(
            valueListenable: valueNotifier,
            builder: (_, __, ___) => Column(
              spacing: 5,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${percentage.toStringAsFixed(2)}%',
                  style: TextStyle(
                      color: AppColor.darkText,
                      fontWeight: FontWeight.w300,
                      fontSize: (isSmallScreen ? 25 : 40).sp
                  ),
                ),

                SizedBox(
                  width: textWidth * 2.5,
                  child: Text(
                    prop.label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: prop.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 16
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BalanceText(
                      balance: prop.actualAmount,
                      currencyName: currency.toString(),
                      size: 14,
                    ),
                    prop.budget == 0
                    ? SizedBox.shrink()
                    : Row(
                      children: [
                        Text(' / '),
                        BalanceText(
                          balance: prop.budget,
                          currencyName: currency.toString(),
                          size: 14,
                        ),
                      ],
                    )
                  ],
                ),

                prop.budget == 0 && !disabledBudget
                ? Text(
                  'Add Budget!',
                  style: TextStyle(
                      color: AppColor.darkText,
                      fontWeight: FontWeight.w400,
                      fontSize: 14
                  ),
                )
                : SizedBox.shrink(),
              ],
            )
        ),
      ),
    );
  }
}
