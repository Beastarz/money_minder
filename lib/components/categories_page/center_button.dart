import 'package:flutter/material.dart';
import 'package:money_minder/utils/balance_text.dart';

import '../../models/currency.dart';
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
  final Currency mainCurrency;

  const CenterButton({
    super.key,
    required this.centerButtonOnPressed,
    required this.isExpense,
    required this.totalExpense,
    required this.totalIncome,
    required this.mainCurrency,
  });

  @override
  Widget build(BuildContext context) {

    final bool isSmallScreen = MediaQuery.of(context).size.width <= 360;

    return Center( // Center the button horizontally
      child: SizedBox(
        width: MediaQuery.of(context).size.width * (
          isSmallScreen ? 0.2 : 0.3
        ),
        height: MediaQuery.of(context).size.width * (
          isSmallScreen ? 0.2 : 0.3
        ),
        child: MaterialButton(
          onPressed: centerButtonOnPressed,
          padding: EdgeInsets.zero,
          shape: const CircleBorder(),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: isSmallScreen ? 5 : AppSize.gap,
            children: [
              Text(
                isExpense ? 'Expenses' : 'Income',
                style: TextStyle(
                  color: AppColor.darkText,
                  fontSize: isSmallScreen ? 15 : AppSize.heading1,
                ),
                textAlign: TextAlign.center,
              ),


              // in expense mode, showing the total expense, then total income
              // in income mode, showing the total income, then total expense
              BalanceText(
                  balance: isExpense ? totalExpense : totalIncome,
                  currencyName: mainCurrency.toString(),
                  showColor: true,
                  fontColor: isExpense
                      ? Colors.redAccent
                      : Colors.green,
                  mainAxisAlignment: MainAxisAlignment.center,
                  size: isSmallScreen ? 11 : AppSize.heading2,
              ),
              BalanceText(
                  balance: isExpense ? totalIncome : totalExpense,
                  currencyName: mainCurrency.toString(),
                  showColor: true,
                  fontColor: isExpense
                      ? Colors.green
                      : Colors.redAccent,
                  mainAxisAlignment: MainAxisAlignment.center,
                  size: isSmallScreen ? 10 : AppSize.heading3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
