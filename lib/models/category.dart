import 'package:flutter/material.dart';

import '../style/app_color.dart';

class Category{
  final int id;
  final String label;
  final int position;
  final Icon icon;
  final Color color;
  final bool isExpense;
  final double expectedAmount;

  Category({
    required this.id,
    required this.label,
    required this.position,
    required this.icon,
    required this.color,
    required this.isExpense,
    required this.expectedAmount,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      label: map['label'],
      position: map['position'],
      icon: Icon(
        IconData(
            map['icon'] as int,
            fontFamily: 'MaterialSymbolsOutlined'
        ),
        color: AppColor.lightIcon,
      ),
      color: Color(map['color'] as int),
      isExpense: map['is_expense'] == 1 ? true : false,
      expectedAmount: map['expected_amount'],
    );
  }

  static Map<String, dynamic> insertAsMap({
    required String label,
    required int position,
    required Icon icon,
    required Color color,
    required bool isExpense,
    required double expectedAmount,
  }) {
    return {
      'label': label,
      'position': position,
      'icon': icon.icon?.codePoint,
      'color': color.toARGB32().toString(),
      'is_expense': isExpense ? 0 : 1,
      'expected_amount': expectedAmount,
    };
  }
}