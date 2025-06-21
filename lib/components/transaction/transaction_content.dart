import 'package:flutter/material.dart';
import 'package:money_minder/components/transaction/transaction_tile.dart';
import 'package:money_minder/models/currency.dart';
import 'package:money_minder/models/recurrence.dart';
import 'package:money_minder/style/app_color.dart';
import 'package:money_minder/utils/balance_text.dart';

import '../../models/transaction.dart';
import '../recurrence/recurrence_tile.dart';

class TransactionsContent extends StatelessWidget {
  const TransactionsContent({super.key, required this.transactions, required this.initialBalance, required this.finalBalance, required this.mainCurrency, required this.onTransactionReload, required this.isInFiltered, required this.recurrences, required this.clearTransactionFilters,});

  final List<Transaction> transactions;
  final List<Recurrence> recurrences;
  final double initialBalance;
  final double finalBalance;
  final Currency mainCurrency;
  final bool isInFiltered;
  final Function clearTransactionFilters;
  final Function() onTransactionReload;

  @override
  Widget build(BuildContext context) {
    List<List<Transaction>> groupedTransactionsByDate = groupTransactionsByDate(transactions.reversed.toList());
    List<List<Transaction>> groupedRecurrencesByDate = groupTransactionsByDate(recurrences.reversed.toList());

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.03, vertical: 16),
      child: Column(
        spacing: 8,
        children: <Widget> [
          isInFiltered
              ? TextButton(onPressed: () => clearTransactionFilters() , child: Text('Clear Filters', style: TextStyle(color: Colors.red),))
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: MediaQuery.of(context).size.width*0.05,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColor.secondary
                ),
                width: MediaQuery.of(context).size.width * 0.40,
                height: 80,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Starting Balance'),
                    BalanceText(
                      balance: initialBalance,
                      currencyName: mainCurrency.toString(),
                      textWidth: MediaQuery.of(context).size.width * 0.28,
                      mainAxisAlignment: MainAxisAlignment.center,
                    ),
                  ]
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColor.secondary
                ),
                width: MediaQuery.of(context).size.width * 0.40,
                height: 80,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Ending Balance'),
                      Flexible(
                        child: BalanceText(
                          balance: finalBalance,
                          textWidth: MediaQuery.of(context).size.width * 0.28,
                          currencyName: mainCurrency.toString(),
                          mainAxisAlignment: MainAxisAlignment.center,
                        ),
                      ),
                    ]
                ),
              )
            ],
          ),
          /// Recurrence
          recurrences.isEmpty ? Container() : ExpansionTile(
            title: Text("Upcoming Transactions (${recurrences.length})", style: TextStyle(fontSize: 16),),
            minTileHeight: 20,
            children: groupedRecurrencesByDate.map((r) => RecurrenceTile(recurrences: List.castFrom<Transaction, Recurrence>(r), onTransactionReload: onTransactionReload,)).toList(),
          )
          /// Transactions
        ] + List<Widget>.from(transactions.isEmpty ? [Center(child: Text('No Transactions Here'),)] : groupedTransactionsByDate.map((t) => TransactionTile(transactions: t, onTransactionReload: onTransactionReload,)).toList(),)
      ),
    );
  }

  List<List<Transaction>> groupTransactionsByDate(List<Transaction> transactions) {
    if (transactions.isEmpty) return [];
    transactions.sort((a, b) => a.date.isAtSameMomentAs(b.date) ? 0 : a.date.isBefore(b.date) ? 1 : -1);
    List<List<Transaction>> res = [];
    List<Transaction> temp = [transactions.first];
    for (Transaction t in transactions.sublist(1)) {
      if (t.date.isAtSameMomentAs(temp.last.date)) {
        temp.add(t);
      } else {
        res.add(temp);
        temp = [t];
      }
    }
    if (temp.isNotEmpty) res.add(temp);
    return res;
  }
}
