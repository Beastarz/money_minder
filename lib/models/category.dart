import 'package:flutter/material.dart';

import '../style/app_color.dart';

class Category{
  final int id;
  final String name;
  final int position;
  final Icon icon;
  final Color color;
  final bool isExpense;

  Category({
    required this.id,
    required this.name,
    required this.position,
    required this.icon,
    required this.color,
    required this.isExpense,
  });

  /// use this to convert map to category
  ///
  /// Parameters:
  ///
  /// Map\<String, dynamic\> map: map to be converted
  ///
  /// Returns: Category
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
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
    );
  }

  /// use this to convert category to map
  ///
  /// Parameters:
  ///
  /// String label: label of the category
  ///
  /// int position: position of the category
  ///
  /// int codePoint: icon's code point of the category
  ///
  /// int colorValue: color's value of the category
  ///
  /// bool isExpense: is expense or income
  ///
  /// Returns: map of category
  static Map<String, dynamic> insertAsMap({
    required String name,
    required int position,
    required int codePoint,
    required int colorValue,
    required bool isExpense,
  }) {
    return {
      'name': name,
      'position': position,
      'icon': codePoint,
      'color': colorValue,
      'is_expense': isExpense ? 1 : 0,
    };
  }
}