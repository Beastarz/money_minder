import 'package:flutter/material.dart';

import '../../models/currency.dart';
import '../../style/app_size.dart';
import 'budget_helper.dart';
import 'budget_sheet.dart';
import 'budget_tile.dart';

class BudgetPageContent extends StatefulWidget {
  const BudgetPageContent({
    super.key,
    required this.props,
    required this.totalAmounts,
    required this.mainCurrency,
    required this.startDate,
  });

  final List<List<List<BudgetTileProp>>> props;
  final List<double> totalAmounts;
  final Currency mainCurrency;
  final DateTime startDate;

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

    final buttonWidth = MediaQuery.of(context).size.width * 0.25;
    final isSmallScreen = MediaQuery.of(context).size.width <= 360;

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
                    "Expenses", _type,
                    widget.mainCurrency, widget.totalAmounts[0], buttonWidth
                    , 1, 0.5, isSmallScreen ? 0.8 : 1.2),
                BudgetHelper.buildCatButton(() {switchContent("Savings");},
                    "Savings", _type,
                    widget.mainCurrency, widget.totalAmounts[1], buttonWidth
                    , 0.5, 0.5, isSmallScreen ? 0.8 : 1.2),
                BudgetHelper.buildCatButton(() {switchContent("Income");},
                    "Income", _type,
                    widget.mainCurrency, widget.totalAmounts[2], buttonWidth
                    , 0.5, 1, isSmallScreen ? 0.8 : 1.2),
              ],
            ),

            // budget sheet
            BudgetSheet(
              type: _type,
              props: widget.props,
              totalAmounts: widget.totalAmounts,
              mainCurrency: widget.mainCurrency,
              startDate: widget.startDate,
            ),
          ],
        )
    );
  }
}