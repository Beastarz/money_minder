import 'package:flutter/material.dart';

abstract class BudgetTile extends StatelessWidget {

  final Color color;
  final double actualAmount;
  final double expectedAmount;

  const BudgetTile({
    super.key,
    required this.color,
    required this.actualAmount,
    required this.expectedAmount,
  });
}

class MainTile extends BudgetTile {

  final String type; // can be savings, expenses, incomes

  const MainTile({
    super.key,
    required super.color,
    required super.actualAmount,
    required super.expectedAmount,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Text("$type $actualAmount $expectedAmount");
  }
}

class SubTile extends BudgetTile {
   final Icon icon;
   final String label;

   const SubTile({
     super.key,
     required super.color,
     required super.actualAmount,
     required super.expectedAmount,
     required this.label,
     required this.icon,
   });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Text("$label $actualAmount $expectedAmount");
  }
}
