import 'package:flutter/material.dart';

import '../../models/currency.dart';
import '../categories_page/categories_button.dart';
import 'budget_helper.dart';
import 'budget_tile.dart';

class BudgetSheet extends StatelessWidget {

  final String type;
  final List<List<List<BudgetTileProp>>> props;
  final List<double> totalAmounts;
  final Currency mainCurrency;

  const BudgetSheet({
    super.key,
    required this.type,
    required this.props,
    required this.totalAmounts,
    required this.mainCurrency,
  });

  double getTotalExpectedAmount(int index) {
    double total = 0;
    for (BudgetTileProp prop in props[index][1]) {
      total += prop.budget;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    int index = type == "Expenses" ? 0 : type == "Savings" ? 1 : 2;
    BudgetTileProp mainBudgetTileProp = BudgetTileProp(
        label: type,
        color: BudgetHelper.colorMap[type]!,
        actualAmount: totalAmounts[index],
        budget: getTotalExpectedAmount(index),
        type: type
    );
    return
      Column(
        children: [

          // main budget tile
          MainBudgetTile(
            prop: mainBudgetTileProp,
            totalAmount: totalAmounts[index],
          ),

          // cat / acc with budget specified
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: props[index][1].length,
            itemBuilder: (context, i) {
              return BudgetTile(
                prop: props[index][1][i]
              );
            }
          ),

          // cat / acc without budget specified
          ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: props[index][0].length,
              itemBuilder: (context, i) {
                return BudgetTile(
                    prop: props[index][0][i]
                );
              }
          )
        ],
      );
  }
}