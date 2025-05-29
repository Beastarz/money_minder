import 'package:flutter/material.dart';

class BudgetSheet extends StatefulWidget {

  final bool isExpense;

  const BudgetSheet({
    super.key,
    required this.isExpense,
  });

  @override
  State<BudgetSheet> createState() => _BudgetSheetState();
}


class _BudgetSheetState extends State<BudgetSheet> {

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}