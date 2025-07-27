import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_minder/models/category.dart';
import 'package:money_minder/style/app_color.dart';

void main() {
  group('Category model', () {
    test('fromMap correctly creates a Category instance', () {
      final map = {
        'id': 1,
        'name': 'Food',
        'position': 0,
        'icon': Icons.fastfood.codePoint,
        'color': 0xFFFF0000,
        'is_expense': 1,
      };

      final category = Category.fromMap(map);

      expect(category.id, 1);
      expect(category.name, 'Food');
      expect(category.position, 0);
      expect(category.icon.icon!.codePoint, Icons.fastfood.codePoint);
      expect(category.icon.color, AppColor.lightIcon);
      expect(category.color, const Color(0xFFFF0000)); // Colors.red
      expect(category.isExpense, true);
    });

    test('insertAsMap returns correct map for category fields', () {
      final map = Category.insertAsMap(
        name: 'Transport',
        position: 1,
        codePoint: Icons.directions_bus.codePoint,
        colorValue: Colors.blue.toARGB32(),
        isExpense: false,
      );

      expect(map['name'], 'Transport');
      expect(map['position'], 1);
      expect(map['icon'], Icons.directions_bus.codePoint);
      expect(map['color'], Colors.blue.toARGB32());
      expect(map['is_expense'], 0);
    });
  });
}
