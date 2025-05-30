import 'package:flutter/material.dart';

class BudgetTileProp {
  final String label;
  final Color color;
  final double actualAmount;
  final double budget;
  final String type;
  final IconData? iconData;

  const BudgetTileProp({
    required this.label,
    required this.color,
    required this.actualAmount,
    required this.budget,
    required this.type,
    this.iconData,
  });
}

class BudgetTile extends StatelessWidget {

  final BudgetTileProp prop;

  const BudgetTile({
    super.key,
    required this.prop,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        prop.iconData == null ? SizedBox.shrink() : Icon(prop.iconData, color: prop.color),
        Text("${prop.label} ${prop.actualAmount} ${prop.budget}"),
      ],
    );
  }
}

class MainBudgetTile extends BudgetTile  {

  final double totalAmount;

  const MainBudgetTile({
    super.key,
    required super.prop,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text("${prop.label} ${prop.actualAmount} ${prop.budget}"),
      ],
    );
  }
}
