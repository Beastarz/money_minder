import 'package:flutter/material.dart';

import '../../models/currency.dart';
import '../../style/app_color.dart';
import '../../style/app_size.dart';
import '../categories_page/categories_button.dart';
import 'budget_helper.dart';
import 'budget_sheet.dart';
import 'budget_tile.dart';

class BudgetPageContent extends StatefulWidget {
  const BudgetPageContent({
    super.key,
    required this.props,
    required this.totalAmounts,
    required this.mainCurrency,
  });

  final List<List<List<BudgetTileProp>>> props;
  final List<double> totalAmounts;
  final Currency mainCurrency;

  @override
  State<BudgetPageContent> createState() => _BudgetPageContentState();
}

class _BudgetPageContentState extends State<BudgetPageContent> {

  String _type = "Expenses";

  // switch between expense sheet and income sheet
  void switchContent(String type) {
    setState(() {
      _type = type;
    });
  }

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
        padding: EdgeInsets.all(AppSize.bigPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // button to choose whether to display expenses or savings
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 5,
              children: [
                // expense button
                BudgetHelper.buildCatButton(() {switchContent("Expenses");},
                    "Expenses", _type, 1, 0.5),
                BudgetHelper.buildCatButton(() {switchContent("Savings");},
                    "Savings", _type, 0.5, 0.5),
                BudgetHelper.buildCatButton(() {switchContent("Income");},
                    "Income", _type, 0.5, 1),
              ],
            ),

            // budget sheet
            BudgetSheet(
              type: _type,
              props: widget.props,
              totalAmounts: widget.totalAmounts,
              mainCurrency: widget.mainCurrency,
            ),
          ],
        )
    );
  }
}