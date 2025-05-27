import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../style/app_color.dart';
import '../../style/app_size.dart';

class CenterButton extends StatelessWidget {

  /// variable
  // toggle between expenses and income
  final void Function()? centerButtonOnPressed;
  // track if currently showing expense or income
  final bool isExpense;
  final double totalExpense;
  final double totalIncome;

  const CenterButton({
    super.key,
    required this.centerButtonOnPressed,
    required this.isExpense,
    required this.totalExpense,
    required this.totalIncome,
  });

  @override
  Widget build(BuildContext context) {
    return Center( // Center the button horizontally
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.3,
        height: MediaQuery.of(context).size.width * 0.3,
        child: MaterialButton(
          onPressed: centerButtonOnPressed,
          padding: EdgeInsets.zero,
          shape: const CircleBorder(),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
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
