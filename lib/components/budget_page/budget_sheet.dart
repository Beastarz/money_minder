import 'package:flutter/material.dart';

class BudgetSheet extends StatelessWidget {

  final bool isExpense;

  const BudgetSheet({
    super.key,
    required this.isExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Budget ${isExpense ? "Expense" : "Income"} Page"),
    );
  }
}
