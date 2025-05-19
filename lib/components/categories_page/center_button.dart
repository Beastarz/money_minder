import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../style/app_color.dart';
import '../../style/app_size.dart';

class CenterButton extends StatelessWidget {

  /// variable
  // toggle between expenses and income
  void Function()? centerButtonOnPressed;
  // track if currently showing expense or income
  bool isExpense;

  final double totalIncome = 1000.00;
  final double totalExpense = 500.00;

  CenterButton({
    super.key,
    required this.centerButtonOnPressed,
    required this.isExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Center( // Center the button horizontally
      child: SizedBox(
        width: min(MediaQuery.of(context).size.width * 0.5, 250),
        height: min(MediaQuery.of(context).size.width * 0.5, 250),
        child: ElevatedButton(
          onPressed: centerButtonOnPressed,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: EdgeInsets.zero,
            backgroundColor: AppColor.secondary,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: AppSize.gap,
            children: [
              Text(
                isExpense ? 'Expenses' : 'Income',
                style: TextStyle(
                    color: AppColor.darkText,
                    fontSize: AppSize.heading1,
                ),
                textAlign: TextAlign.center,
              ),
              // You can add a pie chart icon here using an Image.asset or SvgPicture.
              // If you have a pie chart SVG, use SvgPicture.


              // in expense mode, showing the total expense, then total income
              // in income mode, showing the total income, then total expense
              Text(
                '\$${isExpense? totalExpense : totalIncome}',
                style: TextStyle(
                  fontSize: AppSize.heading2,
                  color: isExpense
                      ? Colors.redAccent
                      : CupertinoColors.activeGreen,
                ),
              ),
              Text(
                '\$${isExpense? totalIncome : totalExpense}',
                style: TextStyle(
                  fontSize: AppSize.heading3,
                  color: isExpense
                      ? CupertinoColors.activeGreen
                      : Colors.redAccent,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
