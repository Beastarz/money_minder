import 'package:flutter/material.dart';

class Account {
  late int id;
  late String name;
  late double balance;
  late Icon icon;
  late Color color;
  late String description;
  late bool isMain;
  late bool isIncludesInTotal;

  Account(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    balance = map['balance'];
    icon = Icon(
      IconData(map['icon'] as int),
    );
    color = Color(map['color'] as int);
    description = map['description'];
    isMain = map['is_main'] == 1 ? true : false;
    isIncludesInTotal = map['includes_in_total'] == 1 ? true : false;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
      'icon': icon.icon?.codePoint,
      'color': color.toARGB32().toString(),
      'description': description,
      'is_main': isMain ? 1 : 0,
      'includes_in_total': isIncludesInTotal ? 1 : 0,
    };
  }
}