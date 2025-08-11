import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
            spacing: AppSize.gap.w,
            children: [
              Text(
                isExpense ? 'Expenses' : 'Income',
                style: TextStyle(
                  color: AppColor.darkText,
                  fontSize: AppSize.heading1.sp,
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
                  size: AppSize.heading2,
              ),
              BalanceText(
                  balance: isExpense ? totalIncome : totalExpense,
                  currencyName: mainCurrency.toString(),
                  showColor: true,
                  fontColor: isExpense
                      ? Colors.green
                      : Colors.redAccent,
                  mainAxisAlignment: MainAxisAlignment.center,
                  size: AppSize.heading3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
