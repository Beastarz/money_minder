import 'package:flutter/material.dart';

import 'currency.dart';

enum AccountType {
  accounts,
  savings,
  debts
}

class Account {
  final int id;
  final String name;
  final double balance;
  final Icon icon;
  final Color color;
  final String description;
  final bool isMain;
  final bool isIncludesInTotal;
  final AccountType type;
  final Currency currency;
  final int position;

  Account({
    required this.id,
    required this.name,
    required this.balance,
    required this.icon,
    required this.color,
    required this.description,
    required this.isMain,
    required this.isIncludesInTotal,
    required this.type,
    required this.currency,
    required this.position,
  });

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'],
      name: map['name'],
      balance: map['balance'],
      icon: Icon(
        IconData(map['icon'] as int, fontFamily: 'MaterialSymbolsOutlined'),
      ),
      color: Color(map['color'] as int),
      description: map['description'],
      isMain: map['is_main'] == 1 ? true : false,
      isIncludesInTotal: map['includes_in_total'] == 1 ? true : false,
      type: map['type'] == 'savings'
          ? AccountType.savings
          : map['type'] == 'debts'
          ? AccountType.debts
          : AccountType.accounts,
      currency: Currency.of(map['currency']),
      position: map['position'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
      'icon': icon.icon?.codePoint,
      'color': color.toARGB32(),
      'description': description,
      'is_main': isMain ? 1 : 0,
      'includes_in_total': isIncludesInTotal ? 1 : 0,
      'type': type.name,
      'currency': currency.currency().name,
      'position': position,
    };
  }

  static Map<String, dynamic> insertAsMap({
    required String name,
    required double balance,
    required Icon icon,
    required Color color,
    required String description,
    required bool isIncludesInTotal,
    required AccountType type,
    required Currency currency,
  }) {
    return {
      'name': name,
      'balance': balance,
      'icon': icon.icon?.codePoint,
      'color': color.toARGB32(),
      'description': description,
      'is_main': 0,
      'includes_in_total': isIncludesInTotal ? 1 : 0,
      'type': type.name,
      'currency': currency
          .currency()
          .name,
    };
  }

  static double calculateBalance(List<Account> accounts, Currency mainCurrency) {
    double total = 0;
    for (var account in accounts) {
      total +=
          Currency.convert(account.currency, mainCurrency, account.balance);
    }
    return total;
  }

  Account copyWith({int? id,
    String? name,
    double? balance,
    Icon? icon,
    Color? color,
    String? description,
    bool? isMain,
    bool? isIncludesInTotal,
    AccountType? type,
    Currency? currency,
    int? position
  }) {
    return Account(
        id: id ?? this.id,
        name: name ?? this.name,
        balance: balance ?? this.balance,
        icon: icon ?? this.icon,
        color: color ?? this.color,
        description: description ?? this.description,
        isMain: isMain ?? this.isMain,
        isIncludesInTotal: isIncludesInTotal ?? this.isIncludesInTotal,
        type: type ?? this.type,
        currency: currency ?? this.currency,
        position: position ?? this.position,
    );
  }
}