import 'package:flutter/material.dart';

class StatisticsSheet extends StatelessWidget {

  final bool isExpense;

  const StatisticsSheet({
    super.key,
    required this.isExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Statistics ${isExpense ? "Expense" : "Income"} Page"),
    );
  }
}
