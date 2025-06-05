import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:money_minder/utils/balance_text.dart';

import '../../models/currency.dart';
import '../../style/app_color.dart';
import '../../style/app_size.dart';

class BudgetSelectionPage extends StatefulWidget {

  final double expenseAsBudget;
  final Currency mainCurrency;
  final double lastBudget;
  final int month;
  final int year;

  const BudgetSelectionPage({
    super.key,
    required this.expenseAsBudget,
    required this.mainCurrency,
    required this.lastBudget,
    required this.month,
    required this.year,
  });

  @override
  State<BudgetSelectionPage> createState() => _BudgetSelectionPageState();
}

class _BudgetSelectionPageState extends State<BudgetSelectionPage> {

  int? _numOfMonths = 3;
  bool? _clicked = false;

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
                value: _clicked,
                onChanged: (bool? value) {
                  setState(() {
                    value = value ?? false;
                    _clicked = value;
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
                  value: _clicked,
                  onChanged: (bool? value) {
                    setState(() {
                      value = value ?? false;
                      _clicked = value;
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
                            setState(() {
                              _numOfMonths = newValue;
                            });
                          },
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
                  value: _clicked,
                  onChanged: (bool? value) {
                    setState(() {
                      value = value ?? false;
                      _clicked = value;
                    });
                  }),

              Divider(),

              MaterialButton(
                onPressed: () {
                  Navigator.pop(context);
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
