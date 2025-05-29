import 'package:flutter/material.dart';

import '../../models/currency.dart';
import '../categories_page/categories_button.dart';
import 'budget_helper.dart';
import 'budget_tile.dart';

class BudgetSheet extends StatelessWidget {

  final String type;
  final List<List<CategoryButtonProps>> cats;
  final List<double> totalAmounts;
  final Currency mainCurrency;

  const BudgetSheet({
    super.key,
    required this.type,
    required this.cats,
    required this.totalAmounts,
    required this.mainCurrency,
  });

  double getTotalExpectedAmount(int index) {
    double total = 0;
    for (var cat in cats[index]) {
      total += cat.expectedAmount;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    int index = type == "Expenses" ? 0 : type == "Savings" ? 1 : 2;
    return
      Column(
        children: [
          MainTile(
              color: BudgetHelper.colorMap[type]!,
              actualAmount: getTotalExpectedAmount(index),
              expectedAmount: totalAmounts[index],
              type: type
          ),

          ListView.builder(
              shrinkWrap: true,
              itemCount: cats[index].length,
              itemBuilder: (context, i) {
                CategoryButtonProps prop = cats[index][i];
                return SubTile(
                  color: prop.color,
                  actualAmount: prop.actualAmount,
                  expectedAmount: prop.expectedAmount,
                  label: prop.label,
                  icon: prop.icon,
                );
              }
          )
        ],
      );
  }
}