import 'package:money_minder/models/category.dart';

import 'account.dart';

enum  Month {
  jan,
  feb,
  mar,
  apr,
  may,
  jun,
  jul,
  aug,
  sep,
  oct,
  nov,
  dec,
}

class Budget {
  final int id;
  final double amount;
  final String type;
  final Month month;
  final int year;
  final Category? category;
  final Account? account;

  const Budget({
    required this.id,
    required this.amount,
    required this.type,
    required this.month,
    required this.year,
    required this.category,
    required this.account,
  });

  /// use this to convert map to transaction
  factory Budget.fromMap(Map<String, dynamic> map, Category? category, Account? account) {
    return Budget(
      id: map['id'],
      amount: map['amount'],
      type: map['type'],
      month: Month.values[map['month']],
      year: map['year'],
      category: category,
      account: account,
    );
  }
}
