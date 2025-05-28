import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:money_minder/models/transaction.dart';

import '../../models/account.dart';

class TransactionFilter extends StatefulWidget {
  const TransactionFilter({super.key, required this.onFilterChange, required this.transactions, required this.accounts, required this.categories});

  final void Function() onFilterChange;
  final List<Transaction> transactions;
  final List<Account> accounts;
  final List<Category> categories;


  @override
  State<TransactionFilter> createState() => _TransactionFilterState();
}

class _TransactionFilterState extends State<TransactionFilter> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
