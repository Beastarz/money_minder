import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:money_minder/utils/balance_text.dart';
import 'package:money_minder/utils/confirmation_dialog.dart';

import '../../models/currency.dart';
import '../../style/app_color.dart';
import '../../style/app_size.dart';

class BudgetSettingsPage extends StatefulWidget {

  final double expenseAsBudget;
  final Currency mainCurrency;
  final double lastBudget;
  final int month;
  final int year;
  final void Function(int, double) submitSettings;
  final void Function() deleteBudget;

  const BudgetSettingsPage({
    super.key,
    required this.expenseAsBudget,
    required this.mainCurrency,
    required this.lastBudget,
    required this.month,
    required this.year,
    required this.submitSettings,
    required this.deleteBudget,
  });

  @override
  State<BudgetSettingsPage> createState() => _BudgetSettingsPageState();
}

class _BudgetSettingsPageState extends State<BudgetSettingsPage> {

  int _numOfMonths = 3;
  bool _setRecurring = false;
  bool _sameAsAmount = false;
  bool _sameAsPrevious = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
          padding: EdgeInsets.all(AppSize.bigPadding),
          decoration: BoxDecoration(
            color: AppColor.primary,
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppSize.borderRadius)
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.submitSettings(
                      _setRecurring ? _numOfMonths : 0,
                      _sameAsAmount
                      ? widget.expenseAsBudget
                      : _sameAsPrevious
                        ? widget.lastBudget
                        : -1 // does not change the budget
                    );
                  },
                  icon: Icon(Icons.arrow_circle_left_outlined)
              ),

              CheckboxListTile(
                contentPadding: const EdgeInsets.all(0),
                title: Text("Same as Amount (spent / received)"),
                subtitle: BalanceText(
                  balance: widget.expenseAsBudget,
                  currencyName: widget.mainCurrency.toString(),
                  size: 16,
                  fontColor: AppColor.darkText,
                ),
                value: _sameAsAmount,
                onChanged: (bool? value) {
                  setState(() {
                    value = value ?? false;
                    if (!_sameAsAmount) {
                      _sameAsPrevious = false;
                    }
                    _sameAsAmount = value!;
                });
              }),

              // set the same budget as last month budget
              widget.lastBudget == 0
              ? SizedBox.shrink()
              : CheckboxListTile(
                  contentPadding: const EdgeInsets.all(0),
                  title: Text("Same as ${formatDate(DateTime(widget.year, widget.month, 1), [M, ' ', yyyy])}"),
                  subtitle: BalanceText(
                    balance: widget.lastBudget,
                    currencyName: widget.mainCurrency.toString(),
                    size: 16,
                    fontColor: AppColor.darkText,
                  ),
                  value: _sameAsPrevious,
                  onChanged: (bool? value) {
                    setState(() {
                      value = value ?? false;
                      if (!_sameAsPrevious) {
                        _sameAsAmount = false;
                      }
                      _sameAsPrevious = value!;
                    });
                  }),

              // recurrence budget
              CheckboxListTile(
                  contentPadding: const EdgeInsets.all(0),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Set Recurring Budget for",
                        style: TextStyle(fontSize: 16),
                      ),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _numOfMonths,
                          onChanged: (int? newValue) {
                            newValue = newValue ?? 3;
                            setState(() {
                              _numOfMonths = newValue!;
                            });
                          },
                          borderRadius: BorderRadius.circular(AppSize.borderRadius),
                          menuMaxHeight: 200.0, // Adjust as needed
                          items: List.generate(12, (index) {
                            int number = index + 1;
                            return DropdownMenuItem<int>(
                              value: number,
                              child: Text(
                                '$number',
                                style: const TextStyle(fontSize: 16), // Match text style
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const Text(
                        "Month(s).",
                        style: TextStyle(fontSize: 16), // Adjust font size as needed
                      ),
                    ],
                  ),
                  value: _setRecurring,
                  onChanged: (bool? value) {
                    setState(() {
                      value = value ?? false;
                      _setRecurring = value!;
                    });
                  }),

              Divider(),

              MaterialButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return ConfirmationDialog(
                          message: 'Delete Budget?',
                          onConfirm: () {
                            Navigator.pop(context); // pop ConfirmationDialog
                            Navigator.pop(context); // pop BudgetSettingsPage
                            Navigator.pop(context); // pop AddBudgetSheet
                            widget.deleteBudget();
                          }
                      ) ;
                    }
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.delete_outline),
                    SizedBox(width: 10),
                    Text("Delete Budget",
                      style: TextStyle(
                          color: Colors.red
                      )
                    )
                  ]
                ),
              )
            ]
          )
        ),
    );
  }
}