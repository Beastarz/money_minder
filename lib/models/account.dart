import 'package:flutter/material.dart';

import 'currency.dart';

enum AccountType {
  accounts,
  savings,
}

class Account {
  late int id;
  late String name;
  late double balance;
  late Icon icon;
  late Color color;
  late String description;
  late bool isMain;
  late bool isIncludesInTotal;
  late AccountType type;
  late Currency currency;

  Account(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    balance = map['balance'];
    icon = Icon(
      IconData(map['icon'] as int, fontFamily: 'MaterialIcons'),
    );
    color = Color(map['color'] as int);
    description = map['description'];
    isMain = map['is_main'] == 1 ? true : false;
    isIncludesInTotal = map['includes_in_total'] == 1 ? true : false;
    switch(map['type']) {
      case 'accounts':
        type = AccountType.accounts;
        break;
      case 'savings':
        type = AccountType.savings;
        break;
      default:
        type = AccountType.accounts;
        break;
    }
    currency = Currency.of(map['currency']);
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
      'type': type.name,
      'currency': currency.currency().name,
    };
  }
}